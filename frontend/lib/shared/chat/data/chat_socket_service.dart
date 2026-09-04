import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/constants/api_constants.dart';

/// Owns the single WebSocket connection used for both live chat delivery
/// (`message:new` / `message:read` / `conversation:updated`) and WebRTC
/// call signaling (`call:invite` / `call:ready` / `call:offer` /
/// `call:answer` / `call:ice` / `call:leave` / `call:end`) — see
/// `backend/app/api/chat_ws.py` for the server side of this contract.
///
/// One connection is shared for the whole app session (kept alive across
/// screens, not per-conversation): `RealChatRepository`, `CallCubit`, and
/// `IncomingCallService` all listen on [events].
class ChatSocketService {
  ChatSocketService._();

  static final ChatSocketService instance = ChatSocketService._();

  static const _reconnectDelay = Duration(seconds: 3);

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final _eventsController = StreamController<Map<String, dynamic>>.broadcast();

  String? _token;
  bool _manuallyDisconnected = true;
  Timer? _reconnectTimer;

  /// Decoded JSON events pushed by the server, live for as long as
  /// [connect] hasn't been followed by [disconnect].
  Stream<Map<String, dynamic>> get events => _eventsController.stream;

  bool get isConnected => _channel != null;

  /// Opens the socket for [token] (a no-op if already connected with the
  /// same token). Safe to call again after login/token refresh.
  void connect(String token) {
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
    final uri = Uri.parse('${ApiConstants.chatSocketBase}/ws/chat?token=$token');
    final channel = WebSocketChannel.connect(uri);
    _channel = channel;
    _subscription = channel.stream.listen(
      (raw) {
        try {
          final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
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

  void _scheduleReconnect() {
    _channel = null;
    if (_manuallyDisconnected || _token == null) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, _open);
  }

  /// Sends one signaling/typing envelope. No-op while disconnected — the
  /// caller (a call already in progress, say) should treat that as best
  /// effort rather than block on it.
  void send(Map<String, dynamic> event) {
    _channel?.sink.add(jsonEncode(event));
  }

  void disconnect() {
    _manuallyDisconnected = true;
    _token = null;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    unawaited(_channel?.sink.close());
    _channel = null;
  }
}
