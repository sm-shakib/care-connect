import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/constants/api_constants.dart';

/// Owns the single WebSocket connection used for both live chat delivery
/// (`message:new` / `message:read` / `message:deleted` /
/// `conversation:updated`) and WebRTC call signaling (`call:invite` /
/// `call:ready` / `call:offer` / `call:answer` / `call:ice` / `call:leave`
/// / `call:end`) — see `backend/app/api/chat_ws.py` for the server side
/// of this contract.
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
class ChatSocketService with WidgetsBindingObserver {
  ChatSocketService._();

  static final ChatSocketService instance = ChatSocketService._();

  static const _reconnectDelay = Duration(seconds: 3);
  static const _heartbeatInterval = Duration(seconds: 15);
  static const _staleTimeout = Duration(seconds: 35);

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final _eventsController = StreamController<Map<String, dynamic>>.broadcast();

  String? _token;
  bool _manuallyDisconnected = true;
  bool _observerRegistered = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  DateTime _lastActivityAt = DateTime.fromMillisecondsSinceEpoch(0);

  final _readyCompleters = <Completer<void>>[];

  /// Decoded JSON events pushed by the server, live for as long as
  /// [connect] hasn't been followed by [disconnect].
  Stream<Map<String, dynamic>> get events => _eventsController.stream;

  bool get isConnected => _channel != null;

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
    _subscription?.cancel();
    _heartbeatTimer?.cancel();

    final uri = Uri.parse(
      '${ApiConstants.chatSocketBase}/ws/chat?token=$token',
    );
    final channel = WebSocketChannel.connect(uri);
    _channel = channel;

    channel.ready.then(
      (_) {
        _lastActivityAt = DateTime.now();
        _resolveReady();
        _heartbeatTimer = Timer.periodic(
          _heartbeatInterval,
          (_) => _checkHeartbeat(),
        );
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
      onDone: _scheduleReconnect,
      onError: (Object _) => _scheduleReconnect(),
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

  void _scheduleReconnect() {
    _channel = null;
    _heartbeatTimer?.cancel();
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

  /// Resolves once the socket is connected, or after [timeout] — whichever
  /// comes first. Callers that need signaling to actually go out (placing
  /// or answering a call, say) should await this before [send]ing rather
  /// than assuming a prior [connect] already succeeded.
  Future<void> ensureConnected({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (isConnected) return;
    final completer = Completer<void>();
    _readyCompleters.add(completer);
    await completer.future.timeout(timeout, onTimeout: () {});
  }

  /// Sends one signaling/typing envelope. No-op while disconnected — call
  /// [ensureConnected] first for anything that isn't safe to silently drop.
  void send(Map<String, dynamic> event) {
    _channel?.sink.add(jsonEncode(event));
  }

  void disconnect() {
    _manuallyDisconnected = true;
    _token = null;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _subscription?.cancel();
    unawaited(_channel?.sink.close());
    _channel = null;
    if (_observerRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _observerRegistered = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed ||
        _manuallyDisconnected ||
        _token == null)
      return;
    // The socket may look "connected" but be a stale zombie left over from
    // however the OS handled the app while backgrounded — force a fresh
    // one rather than waiting on the heartbeat to notice.
    _subscription?.cancel();
    unawaited(_channel?.sink.close());
    _channel = null;
    _reconnectTimer?.cancel();
    _open();
  }
}
