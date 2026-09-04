import 'package:flutter/material.dart';

import '../data/chat_session.dart';
import '../models/conversation.dart';

/// Wraps a bottom-nav chat icon with a small unread-count badge, live via
/// the same conversation stream the inbox uses.
///
/// Rendering this (it's meant to live in each role's always-mounted
/// bottom nav bar, not just the Chats tab body) is also what starts the
/// chat session/socket as soon as the dashboard loads, rather than only
/// once the user first opens the Chats tab — which matters for
/// `IncomingCallService`, since it can't catch a call before the socket
/// is connected.
class ChatUnreadBadge extends StatelessWidget {
  const ChatUnreadBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChatSession>(
      future: ChatSession.ensureStarted(),
      builder: (context, snapshot) {
        final session = snapshot.data;
        if (session == null) return child;
        return StreamBuilder<List<Conversation>>(
          stream: session.repository.watchConversations(session.currentUser.id),
          builder: (context, conversationSnapshot) {
            final conversations =
                conversationSnapshot.data ?? const <Conversation>[];
            final unread = conversations.fold<int>(
              0,
              (sum, c) => sum + c.unreadCount,
            );
            if (unread <= 0) return child;
            return Badge(
              label: Text(unread > 9 ? '9+' : '$unread'),
              child: child,
            );
          },
        );
      },
    );
  }
}
