import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../call_signaling/call_ring_service.dart';
import '../data/chat_socket_service.dart';
import '../models/call_log_info.dart';
import '../models/call_session.dart';
import '../models/chat_participant.dart';

part 'call_state.dart';

/// Drives the on-screen state of a voice/video call using real WebRTC
/// (`flutter_webrtc`), signaled over `ChatSocketService` — see
/// `backend/app/api/chat_ws.py` for the server side, which only relays
/// these envelopes (it never inspects SDP/ICE contents):
///
/// - `call:invite` — broadcast ring, no SDP yet.
/// - `call:ready` — "I've accepted (or placed) the call, offer me a
///   connection" — every other already-ready participant responds by
///   creating a peer connection and sending `call:offer`. This is how a
///   1:1 call connects (exactly one other ready peer), and how a group
///   call incrementally builds a full mesh as each member joins (every
///   pair of ready participants ends up directly connected — there is no
///   SFU/relay in this app, so mesh is the only way everyone hears
///   everyone without one).
/// - `call:offer` / `call:answer` / `call:ice` — standard per-peer SDP/ICE
///   exchange, addressed with `to_user_id`.
/// - `call:leave` — one participant dropping out of an ongoing *group*
///   call; everyone else just closes that one connection and carries on.
/// - `call:end` — the call is over for everyone (1:1 hangup/decline, or
///   the group call's initiator ending it for all); carries the
///   `outcome`/`duration_seconds` the backend persists as a `call_log`
///   chat message. Only ever sent once per call, by whichever side is
///   ending it "for everyone" (see [_endCall] vs [_leaveGroupCall]).
class CallCubit extends Cubit<CallCubitState> {
  CallCubit({
    required this.currentUserId,
    required String conversationId,
    required List<ChatParticipant> participants,
    required bool isVideo,
    String? groupTitle,
    bool isIncoming = false,
    ChatSocketService? socket,
  }) : _socket = socket ?? ChatSocketService.instance,
       super(
         CallCubitState(
           session: CallSession(
             conversationId: conversationId,
             participants: participants,
             groupTitle: groupTitle,
             isVideo: isVideo,
             isIncoming: isIncoming,
           ),
         ),
       ) {
    _socketSubscription = _socket.events.listen(_handleSignal);
    if (isIncoming) {
      unawaited(
        CallRingService.instance.startIncoming(
          callerName: participants.isNotEmpty
              ? participants.first.name
              : 'Unknown caller',
          isVideo: isVideo,
        ),
      );
    }
    _setUpFuture = _setUp();
    unawaited(_setUpFuture);
  }

  static const _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };
  static const _noAnswerTimeout = Duration(seconds: 45);

  final String currentUserId;
  final ChatSocketService _socket;
  late final StreamSubscription<Map<String, dynamic>> _socketSubscription;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  bool _remoteRendererBound = false;

  final Map<String, RTCPeerConnection> _peers = {};
  final Map<String, bool> _remoteDescriptionSet = {};
  final Map<String, List<RTCIceCandidate>> _pendingCandidates = {};
  final Set<String> _readyPeerIds = {};
  bool _iAmReady = false;

  /// Completes once the renderers are initialized (and, for an
  /// outgoing call, the invite is out). [accept] awaits it so answering
  /// the instant the screen appears can't race the setup.
  late final Future<void> _setUpFuture;

  Timer? _noAnswerTimer;
  Timer? _elapsedTicker;

  String get _conversationId => state.session.conversationId;
  bool get _isVideo => state.session.isVideo;

  Future<void> _setUp() async {
    try {
      await localRenderer.initialize();
      await remoteRenderer.initialize();
    } catch (_) {
      // No video surface available. Audio and signaling are unaffected,
      // and [accept] awaits this future — it must never fail the call.
    }

    if (state.session.isIncoming) {
      // Deliberately no `getUserMedia` yet. The hardware isn't needed
      // until the call is accepted, and opening the audio input takes the
      // focus the ringtone is playing on — so grabbing it here silenced
      // the ring. Wait for accept()/decline().
      return;
    }

    await _acquireLocalMedia();
    // The socket may still be (re)connecting at the exact moment a call is
    // placed — wait rather than silently dropping the invite.
    await _socket.ensureConnected();
    _socket.send({
      'type': 'call:invite',
      'conversation_id': _conversationId,
      'is_video': _isVideo,
    });
    unawaited(CallRingService.instance.startOutgoing());
    _becomeReady();
    _noAnswerTimer = Timer(_noAnswerTimeout, () {
      if (state.session.state == CallState.ringing) {
        _endCall(outcome: CallOutcome.missed);
      }
    });
  }

  /// Opens the mic (and camera, for a video call). Split out of [_setUp]
  /// so an incoming call can defer it until [accept] — see [_setUp].
  Future<void> _acquireLocalMedia() async {
    if (_localStream != null) return;
    await _setAndroidAudioMode(AndroidAudioConfiguration.communication);
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': _isVideo ? {'facingMode': 'user'} : false,
      });
      localRenderer.srcObject = _localStream;
    } catch (_) {
      // Mic/camera denied or unavailable — proceed without local media so
      // signaling/UI still work; peers just won't receive our tracks.
    }
  }

  /// Android runs a WebRTC session in media mode on the loudspeaker unless
  /// told otherwise, which is why call audio came out at speakerphone
  /// volume while the on-screen speaker button still read "off" — nothing
  /// had ever set a route, so the toggle disagreed with what you could
  /// hear. Communication mode is what makes the earpiece the default and
  /// the toggle meaningful. It has to be set before the session starts, so
  /// this runs alongside opening the mic rather than on connect, and it is
  /// put back to [AndroidAudioConfiguration.media] on teardown — left in
  /// communication mode, the *next* call's ringtone would come out of the
  /// earpiece instead of ringing out loud.
  ///
  /// No-op on iOS (the plugin guards it), and never fatal: routing is a
  /// nicety, a call that connects is not.
  Future<void> _setAndroidAudioMode(AndroidAudioConfiguration config) async {
    try {
      await Helper.setAndroidAudioConfiguration(config);
    } catch (_) {
      // Older OS, odd OEM audio HAL — carry on with the system default.
    }
  }

  Future<void> accept() async {
    if (state.session.state != CallState.ringing) return;
    unawaited(CallRingService.instance.stop());
    emit(
      state.copyWith(
        session: state.session.copyWith(state: CallState.connecting),
      ),
    );
    // The renderers are initialized by [_setUp], which may still be in
    // flight if the call was answered the instant it appeared.
    await _setUpFuture;
    await _acquireLocalMedia();
    await _socket.ensureConnected();
    _becomeReady();
  }

  void decline() {
    if (state.session.isGroupCall) {
      _leaveGroupCall();
    } else {
      _endCall(outcome: CallOutcome.declined);
    }
  }

  void endCall() {
    if (state.session.isGroupCall && state.session.isIncoming) {
      _leaveGroupCall();
      return;
    }
    final outcome = state.session.state == CallState.active
        ? CallOutcome.answered
        : CallOutcome.missed;
    _endCall(outcome: outcome);
  }

  void toggleMute() {
    final next = !state.session.isMuted;
    for (final track
        in _localStream?.getAudioTracks() ?? const <MediaStreamTrack>[]) {
      track.enabled = !next;
    }
    emit(state.copyWith(session: state.session.copyWith(isMuted: next)));
  }

  void toggleSpeaker() {
    final next = !state.session.isSpeakerOn;
    unawaited(Helper.setSpeakerphoneOn(next));
    emit(state.copyWith(session: state.session.copyWith(isSpeakerOn: next)));
  }

  void toggleCamera() {
    final next = !state.session.isCameraOn;
    for (final track
        in _localStream?.getVideoTracks() ?? const <MediaStreamTrack>[]) {
      track.enabled = next;
    }
    emit(state.copyWith(session: state.session.copyWith(isCameraOn: next)));
  }

  // ==================== joining the mesh ====================

  void _becomeReady() {
    if (_iAmReady) return;
    _iAmReady = true;
    _socket.send({
      'type': 'call:ready',
      'conversation_id': _conversationId,
      'is_video': _isVideo,
    });
    for (final peerId in _readyPeerIds) {
      unawaited(_connectTo(peerId));
    }
  }

  Future<void> _connectTo(String peerId) async {
    if (_peers.containsKey(peerId)) return;
    final pc = await _createPeerConnection(peerId);
    _peers[peerId] = pc;
    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    _socket.send({
      'type': 'call:offer',
      'conversation_id': _conversationId,
      'to_user_id': peerId,
      'sdp': offer.sdp,
      'sdp_type': offer.type,
    });
  }

  Future<RTCPeerConnection> _createPeerConnection(String peerId) async {
    final pc = await createPeerConnection(_iceServers);
    final localStream = _localStream;
    if (localStream != null) {
      for (final track in localStream.getTracks()) {
        await pc.addTrack(track, localStream);
      }
    }
    pc.onIceCandidate = (candidate) {
      if (candidate.candidate == null) return;
      _socket.send({
        'type': 'call:ice',
        'conversation_id': _conversationId,
        'to_user_id': peerId,
        'candidate': candidate.candidate,
        'sdp_mid': candidate.sdpMid,
        'sdp_mline_index': candidate.sdpMLineIndex,
      });
    };
    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) _bindRemoteStream(event.streams.first);
    };
    pc.onConnectionState = (connectionState) {
      if (connectionState ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _onAnyPeerConnected();
      }
    };
    return pc;
  }

  void _bindRemoteStream(MediaStream stream) {
    // Only the first remote stream is rendered — correct (and sufficient)
    // for 1:1 calls; group video is intentionally out of scope (see class
    // doc comment) so later joiners' video just isn't displayed.
    if (_remoteRendererBound) return;
    _remoteRendererBound = true;
    remoteRenderer.srcObject = stream;
    if (stream.getVideoTracks().isNotEmpty) {
      emit(state.copyWith(hasRemoteVideo: true));
    }
  }

  void _onAnyPeerConnected() {
    _noAnswerTimer?.cancel();
    unawaited(CallRingService.instance.stop());
    if (state.session.state == CallState.active) return;
    // Media is flowing: put it where this kind of call belongs. A voice
    // call goes to the earpiece, like a phone call; a video call keeps the
    // loudspeaker, since the phone isn't at your ear. Emitted with the
    // state so the speaker button shows the route actually in use.
    final speakerOn = _isVideo;
    unawaited(Helper.setSpeakerphoneOn(speakerOn));
    emit(
      state.copyWith(
        session: state.session.copyWith(
          state: CallState.active,
          startedAt: DateTime.now(),
          isSpeakerOn: speakerOn,
        ),
        elapsedSeconds: 0,
      ),
    );
    _elapsedTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
    });
  }

  // ==================== signaling ====================

  void _handleSignal(Map<String, dynamic> event) {
    if (event['conversation_id']?.toString() != _conversationId) return;
    final fromUserId = event['from_user_id'] as String?;
    if (fromUserId == currentUserId) return;

    switch (event['type'] as String?) {
      case 'call:ready':
        if (fromUserId == null) return;
        _readyPeerIds.add(fromUserId);
        if (_iAmReady) unawaited(_connectTo(fromUserId));
      case 'call:offer':
        if (fromUserId != null) unawaited(_handleOffer(fromUserId, event));
      case 'call:answer':
        if (fromUserId != null) unawaited(_handleAnswer(fromUserId, event));
      case 'call:ice':
        if (fromUserId != null) unawaited(_handleRemoteIce(fromUserId, event));
      case 'call:leave':
        if (fromUserId != null) _removePeer(fromUserId);
      case 'call:end':
        _endCall(alreadyNotifiedPeer: true);
    }
  }

  Future<void> _handleOffer(String peerId, Map<String, dynamic> event) async {
    final pc = _peers[peerId] ?? await _createPeerConnection(peerId);
    _peers[peerId] = pc;
    await pc.setRemoteDescription(
      RTCSessionDescription(
        event['sdp'] as String,
        event['sdp_type'] as String?,
      ),
    );
    await _flushPendingCandidates(peerId, pc);
    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    _socket.send({
      'type': 'call:answer',
      'conversation_id': _conversationId,
      'to_user_id': peerId,
      'sdp': answer.sdp,
      'sdp_type': answer.type,
    });
  }

  Future<void> _handleAnswer(String peerId, Map<String, dynamic> event) async {
    final pc = _peers[peerId];
    if (pc == null) return;
    await pc.setRemoteDescription(
      RTCSessionDescription(
        event['sdp'] as String,
        event['sdp_type'] as String?,
      ),
    );
    await _flushPendingCandidates(peerId, pc);
  }

  Future<void> _handleRemoteIce(
    String peerId,
    Map<String, dynamic> event,
  ) async {
    final candidate = RTCIceCandidate(
      event['candidate'] as String?,
      event['sdp_mid'] as String?,
      event['sdp_mline_index'] as int?,
    );
    final pc = _peers[peerId];
    if (pc == null || !(_remoteDescriptionSet[peerId] ?? false)) {
      _pendingCandidates.putIfAbsent(peerId, () => []).add(candidate);
      return;
    }
    await pc.addCandidate(candidate);
  }

  Future<void> _flushPendingCandidates(
    String peerId,
    RTCPeerConnection pc,
  ) async {
    _remoteDescriptionSet[peerId] = true;
    final pending = _pendingCandidates.remove(peerId);
    if (pending == null) return;
    for (final candidate in pending) {
      await pc.addCandidate(candidate);
    }
  }

  void _removePeer(String peerId) {
    final pc = _peers.remove(peerId);
    unawaited(pc?.close());
    _remoteDescriptionSet.remove(peerId);
    _pendingCandidates.remove(peerId);
    _readyPeerIds.remove(peerId);
  }

  // ==================== ending ====================

  /// Drops just this device out of an ongoing group call — nobody else's
  /// call ends, no call log is written (see class doc comment).
  void _leaveGroupCall() {
    if (state.session.state == CallState.ended) return;
    _socket.send({'type': 'call:leave', 'conversation_id': _conversationId});
    _teardown();
  }

  /// Ends the call for everyone: a 1:1 hangup/decline, a missed/unanswered
  /// call, or a group call's initiator wrapping it up for all.
  void _endCall({CallOutcome? outcome, bool alreadyNotifiedPeer = false}) {
    if (state.session.state == CallState.ended) return;
    if (!alreadyNotifiedPeer) {
      _socket.send({
        'type': 'call:end',
        'conversation_id': _conversationId,
        'is_video': _isVideo,
        'outcome': outcome!.name,
        'duration_seconds': state.elapsedSeconds,
      });
    }
    _teardown();
  }

  void _teardown() {
    unawaited(CallRingService.instance.stop());
    unawaited(_setAndroidAudioMode(AndroidAudioConfiguration.media));
    _noAnswerTimer?.cancel();
    _elapsedTicker?.cancel();
    for (final pc in _peers.values) {
      unawaited(pc.close());
    }
    _peers.clear();
    emit(
      state.copyWith(session: state.session.copyWith(state: CallState.ended)),
    );
  }

  @override
  Future<void> close() async {
    await CallRingService.instance.stop();
    // Also restored in [_teardown]; repeated here because a call screen
    // can be disposed without ever having ended cleanly.
    await _setAndroidAudioMode(AndroidAudioConfiguration.media);
    await _socketSubscription.cancel();
    _noAnswerTimer?.cancel();
    _elapsedTicker?.cancel();
    for (final pc in _peers.values) {
      unawaited(pc.close());
    }
    await _localStream?.dispose();
    await localRenderer.dispose();
    await remoteRenderer.dispose();
    return super.close();
  }
}
