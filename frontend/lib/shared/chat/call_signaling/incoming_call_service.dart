import 'dart:async';

import 'package:flutter/material.dart';

import '../data/chat_session.dart';
import '../data/chat_socket_service.dart';
import '../view/call_screen.dart';

/// Catches incoming calls from anywhere in the app — not just while a
/// conversation is open — the same way `MedicineAlarmService` pushes the
/// full-screen medicine alarm from a background notification tap: a
/// singleton, initialized once with the app's `NavigatorState` key, that
/// pushes [CallScreen] itself rather than relying on whatever route
/// happens to be on screen. [CallScreen]'s `CallCubit` is what actually
/// rings (see `CallRingService`).
///
/// Listens on the shared `ChatSocketService` for `call:invite` — the
/// backend never echoes a broadcast back to its sender (see
/// `app/api/chat_ws.py`), so every invite this receives is genuinely for
/// someone else calling.
class IncomingCallService {
  IncomingCallService._();

  static final IncomingCallService instance = IncomingCallService._();

  GlobalKey<NavigatorState>? _navigatorKey;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  /// Conversations currently showing an incoming-call screen — guards
  /// against pushing a second one for the same call while it's ringing.
  final Set<String> _ringingConversationIds = {};

  /// Invites being prepared but not yet on screen. Resolving the
  /// conversation takes a round trip, and a caller who gives up inside
  /// that window sends a `call:end` that no `CallCubit` exists to hear
  /// yet — so it's recorded here and the push is abandoned instead of
  /// opening a call screen that would ring with nobody on the line.
  final Set<String> _pendingConversationIds = {};
  final Set<String> _cancelledConversationIds = {};

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _subscription?.cancel();
    _subscription = ChatSocketService.instance.events.listen(_handleEvent);
  }

  Future<void> _handleEvent(Map<String, dynamic> event) async {
    final conversationId = event['conversation_id']?.toString();
    if (conversationId == null) return;

    switch (event['type']) {
      case 'call:end':
      case 'call:leave':
        if (_pendingConversationIds.contains(conversationId)) {
          _cancelledConversationIds.add(conversationId);
        }
        return;
      case 'call:invite':
        await _ring(conversationId, event);
    }
  }

  Future<void> _ring(String conversationId, Map<String, dynamic> event) async {
    if (_ringingConversationIds.contains(conversationId)) return;
    if (!_pendingConversationIds.add(conversationId)) return;

    try {
      final navigator = _navigatorKey?.currentState;
      if (navigator == null) return;

      final session = await ChatSession.ensureStarted();
      final conversation = await session.repository
          .watchConversation(conversationId)
          .first;
      if (conversation == null) return;

      final others = conversation.participants
          .where((p) => p.id != session.currentUser.id)
          .toList();
      if (others.isEmpty) return;

      // The caller may have hung up while the above was in flight.
      if (_cancelledConversationIds.contains(conversationId)) return;

      _ringingConversationIds.add(conversationId);
      _pendingConversationIds.remove(conversationId);
      try {
        await navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => CallScreen(
              currentUserId: session.currentUser.id,
              conversationId: conversationId,
              participants: others,
              groupTitle: conversation.isGroup
                  ? conversation.displayTitle(session.currentUser.id)
                  : null,
              isVideo: event['is_video'] as bool? ?? false,
              isIncoming: true,
            ),
          ),
        );
      } finally {
        _ringingConversationIds.remove(conversationId);
      }
    } finally {
      _pendingConversationIds.remove(conversationId);
      _cancelledConversationIds.remove(conversationId);
    }
  }
}
