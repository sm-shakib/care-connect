part of 'conversation_cubit.dart';

class ConversationState extends Equatable {
  const ConversationState({
    required this.currentUser,
    this.conversation,
    this.messages = const [],
    this.isLoading = true,
    this.isSearching = false,
    this.searchQuery = '',
    this.searchResultIds = const [],
    this.replyTarget,
  });

  final ChatParticipant currentUser;
  final Conversation? conversation;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSearching;
  final String searchQuery;
  final List<String> searchResultIds;

  /// The message currently staged to reply to — shown as a preview banner
  /// above the composer, cleared once that reply is sent (or dismissed).
  final ChatMessage? replyTarget;

  String get title => conversation?.displayTitle(currentUser.id) ?? '';
  bool get isGroup => conversation?.isGroup ?? false;

  ConversationState copyWith({
    Conversation? Function()? conversation,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSearching,
    String? searchQuery,
    List<String>? searchResultIds,
    ChatMessage? Function()? replyTarget,
  }) {
    return ConversationState(
      currentUser: currentUser,
      conversation: conversation != null ? conversation() : this.conversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResultIds: searchResultIds ?? this.searchResultIds,
      replyTarget: replyTarget != null ? replyTarget() : this.replyTarget,
    );
  }

  @override
  List<Object?> get props => [
    currentUser,
    conversation,
    messages,
    isLoading,
    isSearching,
    searchQuery,
    searchResultIds,
    replyTarget,
  ];
}
