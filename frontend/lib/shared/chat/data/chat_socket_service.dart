import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/constants/api_constants.dart';

/// Owns the single WebSocket connection used for both live chat delivery
/// (`message:new` / `message:read` / `message:deleted` /
/// `conversation:updated` / `typing`) and WebRTC call signaling
/// (`call:invite` / `call:ready` / `call:offer` / `call:answer` /
/// `call:ice` / `call:leave` / `call:end`) — see
/// `backend/app/api/chat_ws.py` for the server side of this contract.
///
/// One connection is shared for the whole app session (kept alive across
/// screens, not per-conversation): `RealChatRepository`, `CallCubit`, and
/// `IncomingCallService` all listen on [events].
///
/// Mobile OSes routinely kill or silently stall background sockets — a
/// dead connection that never receives a TCP-level FIN/RST just sits
/// there looking "connected" while delivering nothing (the exact bug
/// behind chat not updating live and calls never ringing). This class
/// guards against that with a heartbeat: every [_heartbeatInterval] it
/// sends `ping` and expects *some* traffic back within [_staleTimeout];
/// if not, it tears down and reconnects. It also forces a fresh
/// connection whenever the app returns to the foreground, since that's
/// the single most common moment a socket has gone stale.
///
/// Reconnecting alone isn't enough, though: everything pushed while the
/// socket was down is gone for good, so a client that only reconnects
/// silently stays stale until the user backs out and re-enters the
/// screen. Every successful (re)connection therefore emits a synthetic
/// [connectedEvent] on [events], which `RealChatRepository` treats as
/// "refetch whatever you're showing".
class ChatSocketService with WidgetsBindingObserver {
  ChatSocketService._();

  static final ChatSocketService instance = ChatSocketService._();

  /// Synthetic event pushed onto [events] each time the socket finishes
  /// connecting. Not sent by the server — it's the signal to resync
  /// anything that may have been missed while disconnected.
  static const connectedEvent = {'type': 'socket:connected'};

  static const _reconnectDelay = Duration(seconds: 3);
  static const _heartbeatInterval = Duration(seconds: 15);
  static const _staleTimeout = Duration(seconds: 35);

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final _eventsController = StreamController<Map<String, dynamic>>.broadcast();

  String? _token;
  bool _manuallyDisconnected = true;
  bool _observerRegistered = false;

  /// True only once the handshake has actually completed. A channel exists
  /// from the moment [WebSocketChannel.connect] is called, long before it
  /// is usable, so this — not `_channel != null` — is what [isConnected]
  /// and [ensureConnected] report.
  bool _isReady = false;

  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  DateTime _lastActivityAt = DateTime.fromMillisecondsSinceEpoch(0);

  final _readyCompleters = <Completer<void>>[];

  /// Decoded JSON events pushed by the server, live for as long as
  /// [connect] hasn't been followed by [disconnect].
  Stream<Map<String, dynamic>> get events => _eventsController.stream;

  bool get isConnected => _isReady;

  /// Opens the socket for [token] (a no-op if already connected with the
  /// same token). Safe to call again after login/token refresh.
  void connect(String token) {
    if (!_observerRegistered) {
      WidgetsBinding.instance.addObserver(this);
      _observerRegistered = true;
    }
    if (_channel != null && _token == token) return;
    _token = token;
    _manuallyDisconnected = false;
    _reconnectTimer?.cancel();
    _open();
  }

  void _open() {
    final token = _token;
    if (token == null) return;
    _closeChannel();

    final uri = Uri.parse(
      '${ApiConstants.chatSocketBase}/ws/chat?token=$token',
    );
    final channel = WebSocketChannel.connect(uri);
    _channel = channel;

    channel.ready.then(
      (_) {
        // A reconnect that raced with a teardown must not resurrect the
        // heartbeat for a channel nobody is listening to any more.
        if (!identical(_channel, channel)) return;
        _lastActivityAt = DateTime.now();
        _isReady = true;
        _resolveReady();
        _heartbeatTimer?.cancel();
        _heartbeatTimer = Timer.periodic(
          _heartbeatInterval,
          (_) => _checkHeartbeat(),
        );
        _eventsController.add(Map<String, dynamic>.from(connectedEvent));
      },
      onError: (Object _) {
        // The `stream` below also sees this as a done/error event and
        // schedules a reconnect — nothing further to do here beyond not
        // leaving the ready-waiters hanging forever.
      },
    );

    _subscription = channel.stream.listen(
      (raw) {
        _lastActivityAt = DateTime.now();
        try {
          final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
          if (decoded['type'] == 'pong') return;
          _eventsController.add(decoded);
        } catch (_) {
          // Malformed frame — ignore rather than tear down the socket.
        }
      },
      // Guarded on identity: a channel we already replaced still reports
      // done/error as it winds down, and acting on that would tear the
      // *new* healthy connection back down three seconds later.
      onDone: () => _scheduleReconnect(from: channel),
      onError: (Object _) => _scheduleReconnect(from: channel),
      cancelOnError: true,
    );
  }

  void _checkHeartbeat() {
    if (DateTime.now().difference(_lastActivityAt) > _staleTimeout) {
      _scheduleReconnect(); // connection looks dead — force a fresh one
      return;
    }
    send(const {'type': 'ping'});
  }

  /// Drops the current channel and everything hanging off it. Leaving the
  /// old socket open (as this used to) stranded a connection server-side
  /// for every reconnect, so a user accumulated phantom devices that the
  /// backend kept trying to deliver to.
  void _closeChannel() {
    _isReady = false;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    final subscription = _subscription;
    final channel = _channel;
    _subscription = null;
    _channel = null;
    unawaited(subscription?.cancel());
    unawaited(channel?.sink.close());
  }

  void _scheduleReconnect({WebSocketChannel? from}) {
    if (from != null && !identical(_channel, from)) return;
    _closeChannel();
    if (_manuallyDisconnected || _token == null) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, _open);
  }

  void _resolveReady() {
    for (final completer in _readyCompleters) {
      if (!completer.isCompleted) completer.complete();
    }
    _readyCompleters.clear();
  }

  /// Resolves once the socket has finished connecting, or after [timeout]
  /// — whichever comes first. Callers that need signaling to actually go
  /// out (placing or answering a call, say) should await this before
  /// [send]ing rather than assuming a prior [connect] already succeeded.
  ///
  /// If a reconnect is merely pending, this brings it forward instead of
  /// burning the caller's timeout waiting on [_reconnectDelay].
  Future<void> ensureConnected({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (isConnected) return;
    if (_channel == null && !_manuallyDisconnected && _token != null) {
      _reconnectTimer?.cancel();
      _open();
    }
    final completer = Completer<void>();
    _readyCompleters.add(completer);
    await completer.future.timeout(timeout, onTimeout: () {});
  }

  /// Sends one signaling/typing envelope. No-op while disconnected — call
  /// [ensureConnected] first for anything that isn't safe to silently
  /// drop. Writes made while the handshake is still in flight are buffered
  /// by the channel and flushed on connect.
  void send(Map<String, dynamic> event) {
    _channel?.sink.add(jsonEncode(event));
  }

  void disconnect() {
    _manuallyDisconnected = true;
    _token = null;
    _reconnectTimer?.cancel();
    _closeChannel();
    _resolveReady();
    if (_observerRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _observerRegistered = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed ||
        _manuallyDisconnected ||
        _token == null) {
      return;
    }
    // The socket may look "connected" but be a stale zombie left over from
    // however the OS handled the app while backgrounded — force a fresh
    // one rather than waiting on the heartbeat to notice.
    _reconnectTimer?.cancel();
    _open();
  }
}
