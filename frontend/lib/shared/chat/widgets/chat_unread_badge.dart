import 'dart:async';

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
///
/// Stateful on purpose: `watchConversations` returns a fresh
/// single-subscription stream per call, so subscribing to it from inside
/// `build` (as this used to) tore down and re-established the
/// subscription — refetching the whole conversation list over REST — on
/// every rebuild of the nav bar, and left a window with nothing listening
/// for live updates each time.
class ChatUnreadBadge extends StatefulWidget {
  const ChatUnreadBadge({super.key, required this.child});

  final Widget child;

  @override
  State<ChatUnreadBadge> createState() => _ChatUnreadBadgeState();
}

class _ChatUnreadBadgeState extends State<ChatUnreadBadge> {
  StreamSubscription<List<Conversation>>? _subscription;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_listen());
  }

  Future<void> _listen() async {
    try {
      final session = await ChatSession.ensureStarted();
      if (!mounted) return;
      _subscription = session.repository
          .watchConversations(session.currentUser.id)
          .listen((conversations) {
            final unread = conversations.fold<int>(
              0,
              (sum, c) => sum + c.unreadCount,
            );
            if (unread != _unread && mounted) {
              setState(() => _unread = unread);
            }
          });
    } catch (_) {
      // Chat couldn't start (no token yet, network down). The badge just
      // stays bare; `ChatSession.ensureStarted` doesn't cache a failure,
      // so opening the Chats tab retries from scratch.
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_unread <= 0) return widget.child;
    return Badge(
      label: Text(_unread > 9 ? '9+' : '$_unread'),
      child: widget.child,
    );
  }
}
