import 'dart:async';

import 'package:uuid/uuid.dart';

import '../models/call_log_info.dart';
import '../models/chat_message.dart';
import '../models/chat_participant.dart';
import '../models/conversation.dart';
import '../models/message_attachment.dart';
import 'chat_directory.dart';
import 'chat_repository.dart';

/// In-memory, singleton mock of [ChatRepository] seeded with dummy
/// conversations shared across roles (see `chat_directory.dart` for the
/// cast). Kept as one process-wide singleton so the elderly/caregiver/
/// family Chats tabs — and any conversation opened contextually from
/// elsewhere in the app — all see the same state during a session, the
/// same way a real backend would.
class MockChatRepository implements ChatRepository {
  MockChatRepository._() {
    _seed();
  }

  static final MockChatRepository instance = MockChatRepository._();

  static const _uuid = Uuid();

  final Map<String, Conversation> _conversations = {};
  final Map<String, List<ChatMessage>> _messages = {};
  final _changes = StreamController<void>.broadcast();

  void _notify() => _changes.add(null);

  @override
  Stream<List<Conversation>> watchConversations(String userId) async* {
    yield _conversationsFor(userId);
    yield* _changes.stream.map((_) => _conversationsFor(userId));
  }

  List<Conversation> _conversationsFor(String userId) {
    final list = _conversations.values
        .where((c) => c.participants.any((p) => p.id == userId))
        .toList()
      ..sort((a, b) {
        final aTime = a.lastMessage?.timestamp ?? DateTime(2000);
        final bTime = b.lastMessage?.timestamp ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
    return list;
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) async* {
    yield List.unmodifiable(_messages[conversationId] ?? const []);
    yield* _changes.stream.map(
      (_) => List<ChatMessage>.unmodifiable(_messages[conversationId] ?? const []),
    );
  }

  @override
  Stream<Conversation?> watchConversation(String conversationId) async* {
    yield _conversations[conversationId];
    yield* _changes.stream.map((_) => _conversations[conversationId]);
  }

  @override
  Conversation? conversationById(String conversationId) => _conversations[conversationId];

  @override
  Future<List<ChatParticipant>> getContacts(ChatParticipant currentUser) async {
    return ChatDirectory.contactsFor(currentUser);
  }

  @override
  Future<Conversation> createDirectConversation({
    required ChatParticipant currentUser,
    required ChatParticipant other,
  }) async {
    final existing = _conversations.values.where(
      (c) =>
          !c.isGroup &&
          c.participants.length == 2 &&
          c.participants.any((p) => p.id == currentUser.id) &&
          c.participants.any((p) => p.id == other.id),
    );
    if (existing.isNotEmpty) return existing.first;

    final conversation = Conversation(
      id: _uuid.v4(),
      isGroup: false,
      participants: [currentUser, other],
    );
    _conversations[conversation.id] = conversation;
    _messages[conversation.id] = [];
    _notify();
    return conversation;
  }

  @override
  Future<Conversation> createGroupConversation({
    required String title,
    required ChatParticipant createdBy,
    required List<ChatParticipant> members,
  }) async {
    final participants = {createdBy, ...members}.toList();
    final conversation = Conversation(
      id: _uuid.v4(),
      isGroup: true,
      title: title,
      createdBy: createdBy.id,
      participants: participants,
    );
    _conversations[conversation.id] = conversation;
    _messages[conversation.id] = [];
    _notify();
    return conversation;
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required ChatParticipant sender,
    String? text,
    ChatMessageType type = ChatMessageType.text,
    List<MessageAttachment> attachments = const [],
    CallLogInfo? callLog,
  }) async {
    final message = ChatMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: sender.id,
      senderName: sender.name,
      timestamp: DateTime.now(),
      isFromMe: true,
      type: type,
      text: text,
      attachments: attachments,
      status: MessageDeliveryStatus.sending,
      callLog: callLog,
    );
    _messages.putIfAbsent(conversationId, () => []).add(message);
    _bumpLastMessage(conversationId, message);
    _notify();

    // Simulated delivery ticks — the seam a real socket/HTTP client would
    // replace once a chat backend exists.
    unawaited(_simulateDelivery(conversationId, message.id));
    return message;
  }

  Future<void> _simulateDelivery(String conversationId, String messageId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _updateMessageStatus(conversationId, messageId, MessageDeliveryStatus.sent);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _updateMessageStatus(conversationId, messageId, MessageDeliveryStatus.delivered);
  }

  void _updateMessageStatus(
    String conversationId,
    String messageId,
    MessageDeliveryStatus status,
  ) {
    final messages = _messages[conversationId];
    if (messages == null) return;
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;
    messages[index] = messages[index].copyWith(status: status);
    _notify();
  }

  void _bumpLastMessage(String conversationId, ChatMessage message) {
    final conversation = _conversations[conversationId];
    if (conversation == null) return;
    _conversations[conversationId] = conversation.copyWith(lastMessage: message);
  }

  @override
  Future<void> markRead(String conversationId, String userId) async {
    final conversation = _conversations[conversationId];
    if (conversation == null || conversation.unreadCount == 0) return;
    _conversations[conversationId] = conversation.copyWith(unreadCount: 0);
    _notify();
  }

  @override
  Future<List<ChatMessage>> searchMessages(String conversationId, String query) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return const [];
    final messages = _messages[conversationId] ?? const [];
    return messages
        .where((m) => (m.text ?? '').toLowerCase().contains(trimmed))
        .toList();
  }

  @override
  List<MessageAttachment> mediaFor(String conversationId, {AttachmentKind? kind}) {
    final messages = _messages[conversationId] ?? const [];
    final attachments = messages
        .expand((m) => m.attachments)
        .where((a) => kind == null || a.kind == kind)
        .toList();
    return attachments.reversed.toList();
  }

  @override
  Future<void> addMembers(String conversationId, List<ChatParticipant> members) async {
    final conversation = _conversations[conversationId];
    if (conversation == null) return;
    final updated = {...conversation.participants, ...members}.toList();
    _conversations[conversationId] = conversation.copyWith(participants: updated);
    _notify();
  }

  @override
  Future<void> removeMember(String conversationId, String memberId) async {
    final conversation = _conversations[conversationId];
    if (conversation == null) return;
    final updated =
        conversation.participants.where((p) => p.id != memberId).toList();
    _conversations[conversationId] = conversation.copyWith(participants: updated);
    _notify();
  }

  @override
  Future<void> setMuted(String conversationId, bool isMuted) async {
    final conversation = _conversations[conversationId];
    if (conversation == null) return;
    _conversations[conversationId] = conversation.copyWith(isMuted: isMuted);
    _notify();
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    _conversations.remove(conversationId);
    _messages.remove(conversationId);
    _notify();
  }

  // ==================== Seed data ====================

  void _seed() {
    final now = DateTime.now();

    _addConversation(
      id: 'conv-adib-shakib',
      isGroup: false,
      participants: [ChatDirectory.adib, ChatDirectory.shakibKhan],
      messages: [
        _text(
          'conv-adib-shakib',
          ChatDirectory.shakibKhan,
          'Good morning! Just checking in on how the walk went today.',
          now.subtract(const Duration(hours: 3, minutes: 10)),
        ),
        _text(
          'conv-adib-shakib',
          ChatDirectory.adib,
          'I did great, finished a 20 minute walk and heart rate stayed stable.',
          now.subtract(const Duration(hours: 3)),
        ),
        _voice(
          'conv-adib-shakib',
          ChatDirectory.adib,
          now.subtract(const Duration(hours: 2, minutes: 58)),
          const Duration(seconds: 14),
        ),
        _text(
          'conv-adib-shakib',
          ChatDirectory.shakibKhan,
          'That is wonderful to hear, thank you for the update.',
          now.subtract(const Duration(hours: 2, minutes: 55)),
        ),
        _document(
          'conv-adib-shakib',
          ChatDirectory.shakibKhan,
          'Blood_Pressure_Chart.pdf',
          now.subtract(const Duration(hours: 2, minutes: 40)),
        ),
        _callLog(
          'conv-adib-shakib',
          ChatDirectory.adib,
          now.subtract(const Duration(hours: 1)),
          isVideo: true,
          outcome: CallOutcome.answered,
          duration: const Duration(minutes: 4, seconds: 12),
        ),
      ],
    );

    _addConversation(
      id: 'conv-adib-care-team',
      isGroup: true,
      title: "Family Group",
      createdBy: ChatDirectory.shakibKhan.id,
      participants: [
        ChatDirectory.adib,
        ChatDirectory.shakibKhan,
        ChatDirectory.nusratJahan,
      ],
      messages: [
        _text(
          'conv-adib-care-team',
          ChatDirectory.adib,
          'Good morning everyone, I finished the morning walk.',
          now.subtract(const Duration(hours: 3, minutes: 40)),
        ),
        _text(
          'conv-adib-care-team',
          ChatDirectory.shakibKhan,
          'Great. Please make sure lunch is after the blood pressure check.',
          now.subtract(const Duration(hours: 3, minutes: 33)),
        ),
        _text(
          'conv-adib-care-team',
          ChatDirectory.nusratJahan,
          'Noted, I will share the reading once it is taken.',
          now.subtract(const Duration(hours: 3, minutes: 28)),
        ),
        _image(
          'conv-adib-care-team',
          ChatDirectory.nusratJahan,
          now.subtract(const Duration(hours: 3, minutes: 20)),
        ),
        _text(
          'conv-adib-care-team',
          ChatDirectory.shakibKhan,
          'Perfect, thanks Nusrat. I will join the evening call after Maghrib.',
          now.subtract(const Duration(hours: 3, minutes: 8)),
        ),
      ],
      unreadCount: 2,
    );

    _addConversation(
      id: 'conv-rose-shakib',
      isGroup: false,
      participants: [ChatDirectory.roseDawson, ChatDirectory.shakibKhan],
      messages: [
        _text(
          'conv-rose-shakib',
          ChatDirectory.roseDawson,
          'Reached her hydration goal today!',
          now.subtract(const Duration(days: 1)),
        ),
        _text(
          'conv-rose-shakib',
          ChatDirectory.shakibKhan,
          'Excellent, keep it up!',
          now.subtract(const Duration(days: 1)).add(const Duration(minutes: 5)),
        ),
      ],
    );

    _addConversation(
      id: 'conv-asif-sarah',
      isGroup: false,
      participants: [ChatDirectory.asifRahman, ChatDirectory.sarahJenkins],
      messages: [
        _text(
          'conv-asif-sarah',
          ChatDirectory.sarahJenkins,
          'Blood pressure logged at 120/80, all stable today.',
          now.subtract(const Duration(hours: 5)),
        ),
        _text(
          'conv-asif-sarah',
          ChatDirectory.asifRahman,
          'Thank you Sarah, appreciate the update as always.',
          now.subtract(const Duration(hours: 4, minutes: 50)),
        ),
      ],
    );

    _addConversation(
      id: 'conv-abdul-care-team',
      isGroup: true,
      title: "Family Group",
      createdBy: ChatDirectory.asifRahman.id,
      participants: [
        ChatDirectory.abdulKarim,
        ChatDirectory.sarahJenkins,
        ChatDirectory.michaelChen,
        ChatDirectory.asifRahman,
        ChatDirectory.ayeshaRahman,
      ],
      messages: [
        _text(
          'conv-abdul-care-team',
          ChatDirectory.abdulKarim,
          'Good morning everyone, I finished the morning walk.',
          now.subtract(const Duration(hours: 3, minutes: 40)),
        ),
        _text(
          'conv-abdul-care-team',
          ChatDirectory.sarahJenkins,
          'Great. Please make sure lunch is after the blood pressure check.',
          now.subtract(const Duration(hours: 3, minutes: 33)),
        ),
        _text(
          'conv-abdul-care-team',
          ChatDirectory.asifRahman,
          'Noted. I will share the reading once it is taken.',
          now.subtract(const Duration(hours: 3, minutes: 28)),
        ),
        _text(
          'conv-abdul-care-team',
          ChatDirectory.ayeshaRahman,
          'Perfect, I will keep the meds ready by then.',
          now.subtract(const Duration(hours: 3, minutes: 8)),
        ),
        _callLog(
          'conv-abdul-care-team',
          ChatDirectory.michaelChen,
          now.subtract(const Duration(hours: 2)),
          isVideo: false,
          outcome: CallOutcome.missed,
          duration: Duration.zero,
        ),
      ],
      unreadCount: 1,
    );
  }

  void _addConversation({
    required String id,
    required bool isGroup,
    required List<ChatParticipant> participants,
    required List<ChatMessage> messages,
    String? title,
    String? createdBy,
    int unreadCount = 0,
  }) {
    _messages[id] = messages;
    _conversations[id] = Conversation(
      id: id,
      isGroup: isGroup,
      title: title,
      createdBy: createdBy,
      participants: participants,
      lastMessage: messages.isEmpty ? null : messages.last,
      unreadCount: unreadCount,
    );
  }

  ChatMessage _text(
    String conversationId,
    ChatParticipant sender,
    String text,
    DateTime timestamp,
  ) {
    return ChatMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: sender.id,
      senderName: sender.name,
      timestamp: timestamp,
      isFromMe: false,
      type: ChatMessageType.text,
      text: text,
      status: MessageDeliveryStatus.read,
    );
  }

  ChatMessage _voice(
    String conversationId,
    ChatParticipant sender,
    DateTime timestamp,
    Duration duration,
  ) {
    return ChatMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: sender.id,
      senderName: sender.name,
      timestamp: timestamp,
      isFromMe: false,
      type: ChatMessageType.voice,
      status: MessageDeliveryStatus.read,
      attachments: [
        MessageAttachment(
          id: _uuid.v4(),
          kind: AttachmentKind.voice,
          fileName: 'voice-message.m4a',
          duration: duration,
          fileSizeBytes: 24 * 1024,
        ),
      ],
    );
  }

  ChatMessage _document(
    String conversationId,
    ChatParticipant sender,
    String fileName,
    DateTime timestamp,
  ) {
    return ChatMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: sender.id,
      senderName: sender.name,
      timestamp: timestamp,
      isFromMe: false,
      type: ChatMessageType.document,
      status: MessageDeliveryStatus.read,
      attachments: [
        MessageAttachment(
          id: _uuid.v4(),
          kind: AttachmentKind.document,
          fileName: fileName,
          fileSizeBytes: 340 * 1024,
          mimeType: 'application/pdf',
        ),
      ],
    );
  }

  ChatMessage _image(
    String conversationId,
    ChatParticipant sender,
    DateTime timestamp,
  ) {
    return ChatMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: sender.id,
      senderName: sender.name,
      timestamp: timestamp,
      isFromMe: false,
      type: ChatMessageType.image,
      status: MessageDeliveryStatus.read,
      attachments: [
        MessageAttachment(
          id: _uuid.v4(),
          kind: AttachmentKind.image,
          fileName: 'blood-pressure-reading.jpg',
          remoteUrl: 'https://picsum.photos/seed/careconnect-bp/600/800',
          fileSizeBytes: 1200 * 1024,
          width: 1080,
          height: 1440,
        ),
      ],
    );
  }

  ChatMessage _callLog(
    String conversationId,
    ChatParticipant sender,
    DateTime timestamp, {
    required bool isVideo,
    required CallOutcome outcome,
    required Duration duration,
  }) {
    return ChatMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: sender.id,
      senderName: sender.name,
      timestamp: timestamp,
      isFromMe: false,
      type: ChatMessageType.callLog,
      status: MessageDeliveryStatus.read,
      callLog: CallLogInfo(
        isVideo: isVideo,
        outcome: outcome,
        isOutgoing: false,
        duration: duration,
      ),
    );
  }
}
