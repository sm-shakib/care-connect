import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/call_session.dart';
import '../models/chat_participant.dart';

part 'call_state.dart';

/// Drives the on-screen state of a voice/video call. There is no real
/// signaling backend in this app (see `call_session.dart`), so the "other
/// side" answering is simulated with timers; mute/speaker/camera toggles
/// and the local camera preview (wired up in `call_screen.dart`) are real.
class CallCubit extends Cubit<CallCubitState> {
  CallCubit({
    required String conversationId,
    required List<ChatParticipant> participants,
    required bool isVideo,
    String? groupTitle,
    bool isIncoming = false,
  }) : super(
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
    if (isIncoming) {
      // Wait for accept()/decline() from the incoming-call UI.
    } else {
      _placeOutgoingCall();
    }
  }

  Timer? _elapsedTicker;
  Timer? _autoProgressTimer;

  void _placeOutgoingCall() {
    _autoProgressTimer = Timer(const Duration(milliseconds: 2200), () => _connect());
  }

  void accept() {
    if (state.session.state != CallState.ringing) return;
    emit(state.copyWith(session: state.session.copyWith(state: CallState.connecting)));
    _autoProgressTimer = Timer(const Duration(milliseconds: 700), () => _connect());
  }

  void decline() {
    _endCall();
  }

  void _connect() {
    final now = DateTime.now();
    emit(
      state.copyWith(
        session: state.session.copyWith(state: CallState.active, startedAt: now),
        elapsedSeconds: 0,
      ),
    );
    _elapsedTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
    });
  }

  void toggleMute() {
    emit(state.copyWith(session: state.session.copyWith(isMuted: !state.session.isMuted)));
  }

  void toggleSpeaker() {
    emit(
      state.copyWith(session: state.session.copyWith(isSpeakerOn: !state.session.isSpeakerOn)),
    );
  }

  void toggleCamera() {
    emit(
      state.copyWith(session: state.session.copyWith(isCameraOn: !state.session.isCameraOn)),
    );
  }

  void endCall() => _endCall();

  void _endCall() {
    _autoProgressTimer?.cancel();
    _elapsedTicker?.cancel();
    emit(state.copyWith(session: state.session.copyWith(state: CallState.ended)));
  }

  @override
  Future<void> close() {
    _autoProgressTimer?.cancel();
    _elapsedTicker?.cancel();
    return super.close();
  }
}
