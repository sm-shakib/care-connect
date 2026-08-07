part of 'chat_inbox_cubit.dart';

class ChatInboxState extends Equatable {
  const ChatInboxState({
    required this.currentUser,
    this.conversations = const [],
    this.query = '',
    this.isLoading = true,
  });

  final ChatParticipant currentUser;
  final List<Conversation> conversations;
  final String query;
  final bool isLoading;

  /// Conversations filtered by [query], matching against the display
  /// title or the last message's preview text.
  List<Conversation> get filteredConversations {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return conversations;
    return conversations.where((c) {
      final title = c.displayTitle(currentUser.id).toLowerCase();
      final preview = c.lastMessage?.previewText.toLowerCase() ?? '';
      return title.contains(trimmed) || preview.contains(trimmed);
    }).toList();
  }

  ChatInboxState copyWith({
    List<Conversation>? conversations,
    String? query,
    bool? isLoading,
  }) {
    return ChatInboxState(
      currentUser: currentUser,
      conversations: conversations ?? this.conversations,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [currentUser, conversations, query, isLoading];
}
