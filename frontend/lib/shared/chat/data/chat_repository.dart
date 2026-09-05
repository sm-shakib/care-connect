import '../models/chat_message.dart';
import '../models/chat_participant.dart';
import '../models/conversation.dart';
import '../models/message_attachment.dart';

/// Data-access contract for the chat module. [MockChatRepository] is the
/// only implementation today (in-memory, seeded with dummy data) since
/// this app has no backend yet — see `lib/core/network/api_client.dart`.
/// Swap in a real HTTP/WebSocket-backed implementation behind this same
/// interface once that backend exists; nothing above the repository layer
/// (cubits/views) should need to change.
abstract class ChatRepository {
  /// Conversations `userId` is a participant of, most-recent first,
  /// re-emitted whenever anything relevant changes.
  Stream<List<Conversation>> watchConversations(String userId);

  /// Messages in [conversationId], oldest first, re-emitted on change.
  Stream<List<ChatMessage>> watchMessages(String conversationId);

  /// A single conversation (e.g. for its title/participant list), kept
  /// up to date as members are added/removed.
  Stream<Conversation?> watchConversation(String conversationId);

  /// People `currentUser` is allowed to start a conversation with, beyond
  /// whoever is already in one of their existing conversations. Backed by
  /// the hardcoded contact directory in the mock; a real relationship
  /// lookup (family/elder bindings, caregiver bookings) in the real one.
  Future<List<ChatParticipant>> getContacts(ChatParticipant currentUser);

  Future<Conversation> createDirectConversation({
    required ChatParticipant currentUser,
    required ChatParticipant other,
  });

  Future<Conversation> createGroupConversation({
    required String title,
    required ChatParticipant createdBy,
    required List<ChatParticipant> members,
  });

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required ChatParticipant sender,
    String? text,
    ChatMessageType type = ChatMessageType.text,
    List<MessageAttachment> attachments = const [],
    String? replyToMessageId,
  });

  /// "Unsends" a message: only the sender may call this, and only for
  /// their own message. It keeps its place in the thread but renders as
  /// "This message was unsent" for everyone from then on.
  Future<void> unsendMessage(String conversationId, String messageId);

  Future<void> markRead(String conversationId, String userId);

  Future<List<ChatMessage>> searchMessages(String conversationId, String query);

  /// All attachments of [kind] ever sent in [conversationId] (any kind
  /// when null), most-recent first — backs the media/files/voice gallery.
  List<MessageAttachment> mediaFor(
    String conversationId, {
    AttachmentKind? kind,
  });

  Future<void> addMembers(String conversationId, List<ChatParticipant> members);

  Future<void> removeMember(String conversationId, String memberId);

  Conversation? conversationById(String conversationId);

  /// Mutes/unmutes notifications for this conversation.
  Future<void> setMuted(String conversationId, bool isMuted);

  /// Permanently removes a conversation (and its message history) for the
  /// current device — mirrors "Delete chat" in most messaging apps.
  Future<void> deleteConversation(String conversationId);

  /// The other participants currently typing in [conversationId],
  /// re-emitted as people start and stop. Empty when nobody is.
  Stream<List<ChatParticipant>> watchTypingParticipants(String conversationId);

  /// Tells the other participants whether the current user is typing.
  /// Fire-and-forget: a dropped signal only costs a missing indicator, so
  /// this never throws or blocks the composer.
  void setTyping(String conversationId, {required bool isTyping});

  /// Marks [conversationId] as the thread the user is looking at (null
  /// when they leave it). Messages that arrive for the open thread are
  /// read on arrival rather than piling up an unread count the user can
  /// see is wrong, and it's what a reconnect refetches first.
  void setActiveConversation(String? conversationId);
}
