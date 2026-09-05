import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/chat_repository.dart';
import '../models/chat_message.dart';
import '../models/chat_participant.dart';
import '../models/conversation.dart';
import '../models/message_attachment.dart';

part 'conversation_state.dart';

/// Drives a single conversation thread: message history, sending
/// text/attachments/voice notes, in-conversation search, and group
/// membership changes. Used identically from any role's chat surface.
class ConversationCubit extends Cubit<ConversationState> {
  ConversationCubit({
    required this.repository,
    required this.conversationId,
    required this.currentUser,
  }) : super(ConversationState(currentUser: currentUser)) {
    _messagesSub = repository.watchMessages(conversationId).listen((messages) {
      emit(state.copyWith(messages: messages, isLoading: false));
    });
    _conversationSub = repository.watchConversation(conversationId).listen((
      conversation,
    ) {
      emit(state.copyWith(conversation: () => conversation));
    });
    _typingSub = repository.watchTypingParticipants(conversationId).listen((
      participants,
    ) {
      emit(state.copyWith(typingParticipants: participants));
    });
    // Tells the repository this thread is on screen, so messages arriving
    // for it are read on arrival instead of showing the user an unread
    // count for a conversation they're looking at.
    repository.setActiveConversation(conversationId);
    repository.markRead(conversationId, currentUser.id);
  }

  final ChatRepository repository;
  final String conversationId;
  final ChatParticipant currentUser;

  late final StreamSubscription<List<ChatMessage>> _messagesSub;
  late final StreamSubscription<Conversation?> _conversationSub;
  late final StreamSubscription<List<ChatParticipant>> _typingSub;

  Future<void> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final replyToMessageId = state.replyTarget?.id;
    clearReplyTarget();
    await repository.sendMessage(
      conversationId: conversationId,
      sender: currentUser,
      text: trimmed,
      replyToMessageId: replyToMessageId,
    );
  }

  Future<void> sendAttachments(
    List<MessageAttachment> attachments,
    AttachmentKind kind,
  ) async {
    if (attachments.isEmpty) return;
    final type = switch (kind) {
      AttachmentKind.image => ChatMessageType.image,
      AttachmentKind.video => ChatMessageType.video,
      AttachmentKind.document => ChatMessageType.document,
      AttachmentKind.voice => ChatMessageType.voice,
    };
    // A reply only ever anchors to one message — if several attachments
    // are sent together, only the first carries it.
    var replyToMessageId = state.replyTarget?.id;
    clearReplyTarget();
    for (final attachment in attachments) {
      await repository.sendMessage(
        conversationId: conversationId,
        sender: currentUser,
        type: type,
        attachments: [attachment],
        replyToMessageId: replyToMessageId,
      );
      replyToMessageId = null;
    }
  }

  Future<void> sendVoiceMessage(MessageAttachment voiceNote) async {
    final replyToMessageId = state.replyTarget?.id;
    clearReplyTarget();
    await repository.sendMessage(
      conversationId: conversationId,
      sender: currentUser,
      type: ChatMessageType.voice,
      attachments: [voiceNote],
      replyToMessageId: replyToMessageId,
    );
  }

  /// Called on every keystroke in the composer. The repository handles
  /// the rate limiting (it re-announces on a timer while the flag stays
  /// set), so this only ever states what's true right now.
  void onComposerChanged(String text) {
    repository.setTyping(conversationId, isTyping: text.trim().isNotEmpty);
  }

  /// Stages [message] to be quoted by the next message sent — shown as a
  /// preview banner above the composer until sent or [clearReplyTarget].
  void setReplyTarget(ChatMessage message) {
    emit(state.copyWith(replyTarget: () => message));
  }

  void clearReplyTarget() {
    emit(state.copyWith(replyTarget: () => null));
  }

  /// "Unsends" a message the current user sent — see
  /// `ChatRepository.unsendMessage`.
  Future<void> unsendMessage(String messageId) async {
    await repository.unsendMessage(conversationId, messageId);
  }

  void toggleSearch({bool? open}) {
    final next = open ?? !state.isSearching;
    emit(
      state.copyWith(
        isSearching: next,
        searchQuery: next ? state.searchQuery : '',
      ),
    );
  }

  Future<void> searchInConversation(String query) async {
    emit(state.copyWith(searchQuery: query));
    if (query.trim().isEmpty) {
      emit(state.copyWith(searchResultIds: const []));
      return;
    }
    final results = await repository.searchMessages(conversationId, query);
    emit(state.copyWith(searchResultIds: results.map((m) => m.id).toList()));
  }

  Future<void> addMembers(List<ChatParticipant> members) async {
    await repository.addMembers(conversationId, members);
  }

  Future<void> removeMember(String memberId) async {
    await repository.removeMember(conversationId, memberId);
  }

  Future<void> toggleMute() async {
    final isMuted = state.conversation?.isMuted ?? false;
    await repository.setMuted(conversationId, !isMuted);
  }

  Future<void> deleteConversation() async {
    await repository.deleteConversation(conversationId);
  }

  @override
  Future<void> close() {
    // Leaving the thread must clear both the peers' indicator and this
    // thread's claim on "currently open", or the next message to arrive
    // would be silently marked read while the user is elsewhere.
    repository.setTyping(conversationId, isTyping: false);
    repository.setActiveConversation(null);
    _messagesSub.cancel();
    _conversationSub.cancel();
    _typingSub.cancel();
    return super.close();
  }
}
