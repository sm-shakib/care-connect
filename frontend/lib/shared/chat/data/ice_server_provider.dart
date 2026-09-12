import 'dart:async';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

/// Supplies the ICE servers `CallCubit` hands to every peer connection,
/// fetched from `GET /chat/ice-servers` and cached for as long as the
/// backend says the credentials are good for.
///
/// A STUN server only tells a device its own public address; it can't get
/// media through the carrier-grade NAT most mobile networks sit behind.
/// Those calls connect only through a TURN relay, and the relay's
/// credentials are minted per request server-side (see
/// `backend/app/core/turn.py`) — so unlike the STUN-only list this
/// replaces, they can't simply be a constant compiled into the app.
///
/// Cached rather than fetched per call because a call is placed from a
/// cold screen, where a round trip is latency the user experiences as a
/// call that's slow to start ringing.
class IceServerProvider {
  IceServerProvider._();

  static final IceServerProvider instance = IceServerProvider._();

  /// Used when the fetch fails. This is exactly what the app did before
  /// TURN existed, so a relay outage — or an old build pointed at a
  /// backend without TURN configured — degrades calls to "connects
  /// wherever both networks allow a direct path" instead of breaking
  /// them outright.
  static const _fallback = <Map<String, dynamic>>[
    {'urls': 'stun:stun.l.google.com:19302'},
  ];

  /// Credentials are renewed at this fraction of their advertised
  /// lifetime. A peer connection holds whatever servers it was created
  /// with for the life of the call, so credentials that expire moments
  /// after being handed out would take the relay — and the call — down
  /// with them mid-conversation.
  static const _renewAt = 0.9;

  final ApiClient _apiClient = ApiClient();

  List<Map<String, dynamic>>? _cached;
  DateTime? _expiresAt;
  Future<List<Map<String, dynamic>>>? _inFlight;

  /// The `iceServers` list for a new peer connection.
  Future<List<Map<String, dynamic>>> fetch() {
    final cached = _cached;
    final expiresAt = _expiresAt;
    if (cached != null &&
        expiresAt != null &&
        expiresAt.isAfter(DateTime.now())) {
      return Future.value(cached);
    }
    // A call screen and the incoming-call screen can both ask at the same
    // moment — share one request rather than racing two.
    return _inFlight ??= _load().whenComplete(() => _inFlight = null);
  }

  /// Forgets the cached credentials. Call on logout: they're minted for
  /// one user, and the relay meters usage against them.
  void reset() {
    _cached = null;
    _expiresAt = null;
    _inFlight = null;
  }

  Future<List<Map<String, dynamic>>> _load() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.chatIceServers,
      );
      final data = response.data;
      if (data == null) return _cached ?? _fallback;

      final servers = (data['ice_servers'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Map<String, dynamic>.from)
          .toList();
      if (servers.isEmpty) return _cached ?? _fallback;

      final ttlSeconds = data['ttl_seconds'] as int? ?? 0;
      _cached = servers;
      _expiresAt = DateTime.now().add(
        Duration(seconds: (ttlSeconds * _renewAt).round()),
      );
      return servers;
    } catch (_) {
      // Offline, expired token, backend without TURN configured — none of
      // these should stop a call being attempted.
      return _cached ?? _fallback;
    }
  }
}
