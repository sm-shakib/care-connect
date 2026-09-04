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
/// happens to be on screen.
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

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _subscription?.cancel();
    _subscription = ChatSocketService.instance.events.listen(_handleEvent);
  }

  Future<void> _handleEvent(Map<String, dynamic> event) async {
    if (event['type'] != 'call:invite') return;
    final conversationId = event['conversation_id']?.toString();
    if (conversationId == null) return;
    if (!_ringingConversationIds.add(conversationId)) return;

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
  }
}
