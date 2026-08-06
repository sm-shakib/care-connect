import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/chat_repository.dart';
import '../models/chat_participant.dart';
import '../models/conversation.dart';

part 'chat_inbox_state.dart';

/// Drives the shared "Chats" tab for whichever role is viewing it —
/// elderly, caregiver, or family all use this same cubit, parameterized
/// by [currentUser].
class ChatInboxCubit extends Cubit<ChatInboxState> {
  ChatInboxCubit({required this.repository, required this.currentUser})
      : super(ChatInboxState(currentUser: currentUser)) {
    _subscription = repository.watchConversations(currentUser.id).listen((conversations) {
      emit(state.copyWith(conversations: conversations, isLoading: false));
    });
  }

  final ChatRepository repository;
  final ChatParticipant currentUser;
  late final StreamSubscription<List<Conversation>> _subscription;

  void search(String query) {
    emit(state.copyWith(query: query));
  }

  Future<void> toggleMute(Conversation conversation) {
    return repository.setMuted(conversation.id, !conversation.isMuted);
  }

  Future<void> deleteConversation(String conversationId) {
    return repository.deleteConversation(conversationId);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
