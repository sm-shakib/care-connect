import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/chat_participant.dart';
import 'chat_repository.dart';
import 'chat_socket_service.dart';
import 'chat_wire.dart';
import 'real_chat_repository.dart';

/// Resolves the signed-in user's chat identity (`GET /chat/me`) and opens
/// the realtime socket, bundling both into the pair every dashboard's
/// Chats tab needs. Cached for the app's lifetime (or until [reset], on
/// logout) so switching tabs doesn't re-fetch identity or reconnect.
class ChatSession {
  ChatSession._(this.repository, this.currentUser);

  final ChatRepository repository;
  final ChatParticipant currentUser;

  static Future<ChatSession>? _future;

  /// Starts the session on first call and reuses it after — except on
  /// failure (e.g. the access token hadn't finished being written to
  /// secure storage yet right after login, or a transient network error):
  /// a failed attempt is never cached, so the next call — the badge
  /// rebuilding, the user opening the Chats tab — retries from scratch
  /// instead of wedging chat for the rest of the app session.
  static Future<ChatSession> ensureStarted() {
    final future = _future ??= _start();
    unawaited(
      future.catchError((Object error) {
        if (identical(_future, future)) _future = null;
        throw error;
      }),
    );
    return future;
  }

  static Future<ChatSession> _start() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    if (token == null) {
      throw StateError('Cannot start a chat session before logging in.');
    }
    ChatSocketService.instance.connect(token);

    final response = await ApiClient().get<Map<String, dynamic>>(
      ApiConstants.chatMe,
    );
    final currentUser = chatParticipantFromJson(response.data!);
    final repository = RealChatRepository(currentUserId: currentUser.id);
    return ChatSession._(repository, currentUser);
  }

  /// Clears the cached session and disconnects the socket — call on
  /// logout so the next login (possibly as a different user) starts over.
  ///
  /// The old repository is disposed too. It stays subscribed to the shared
  /// socket otherwise, and since it resolves `isFromMe` against the
  /// [currentUser] it was built with, leaving it alive means the *previous*
  /// account's repository reacting to the next account's messages.
  static void reset() {
    final pending = _future;
    _future = null;
    ChatSocketService.instance.disconnect();
    if (pending == null) return;
    unawaited(
      pending
          .then((session) {
            final repository = session.repository;
            if (repository is RealChatRepository) repository.dispose();
          })
          // A session that never started has nothing to dispose.
          .catchError((Object _) {}),
    );
  }
}

/// Starts (or reuses) a [ChatSession] and hands the resulting repository
/// and current-user identity to [builder] — the seam every dashboard's
/// Chats tab goes through instead of constructing a repository directly.
class ChatSessionGate extends StatelessWidget {
  const ChatSessionGate({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    ChatRepository repository,
    ChatParticipant currentUser,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChatSession>(
      future: ChatSession.ensureStarted(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Could not load chat: ${snapshot.error}'));
        }
        final session = snapshot.data;
        if (session == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return builder(context, session.repository, session.currentUser);
      },
    );
  }
}
