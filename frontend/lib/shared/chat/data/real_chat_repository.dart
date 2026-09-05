import 'dart:async';

import 'package:dio/dio.dart' as dio;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/call_log_info.dart';
import '../models/chat_message.dart';
import '../models/chat_participant.dart';
import '../models/conversation.dart';
import '../models/message_attachment.dart';
import 'chat_repository.dart';
import 'chat_socket_service.dart';
import 'chat_wire.dart';

/// Backend-backed [ChatRepository]: REST (via [ApiClient]) for history and
/// mutations, [ChatSocketService] for live push. Keeps small in-memory
/// caches so the interface's two synchronous members ([conversationById],
/// [mediaFor]) can be served without a network round trip; the caches are
/// seeded by whichever REST call touches that data first and kept current
/// by the socket events handled below — the same "local cache + broadcast
/// notify" shape `MockChatRepository` uses, just fed by a real backend
/// instead of seed data.
class RealChatRepository implements ChatRepository {
  RealChatRepository({required this.currentUserId, ChatSocketService? socket})
    : _socket = socket ?? ChatSocketService.instance {
    _socketSubscription = _socket.events.listen(_handleSocketEvent);
  }

  /// The signed-in user's id, as returned by `GET /chat/me` — used to
  /// resolve `isFromMe`/`isOutgoing` on every message parsed from JSON.
  final String currentUserId;

  final ChatSocketService _socket;
  final ApiClient _apiClient = ApiClient();

  late final StreamSubscription<Map<String, dynamic>> _socketSubscription;
  final _changes = StreamController<void>.broadcast();

  final Map<String, Conversation> _conversations = {};
  final Map<String, List<ChatMessage>> _messages = {};
  final Map<String, List<MessageAttachment>> _media = {};

  void _notify() => _changes.add(null);

  /// Stops listening to the socket. Call when this session ends (e.g.
  /// logout) — see `ChatSession.reset`.
  void dispose() {
    _socketSubscription.cancel();
    unawaited(_changes.close());
  }

  // ==================== conversations ====================

  @override
  Stream<List<Conversation>> watchConversations(String userId) async* {
    yield await _refreshConversations();
    yield* _changes.stream.map((_) => _conversationsSnapshot());
  }

  Future<List<Conversation>> _refreshConversations() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.chatConversations,
    );
    for (final raw in response.data ?? const []) {
      final conversation = _conversationFromJson(raw as Map<String, dynamic>);
      _conversations[conversation.id] = conversation;
    }
    return _conversationsSnapshot();
  }

  List<Conversation> _conversationsSnapshot() {
    final list = _conversations.values.toList()
      ..sort((a, b) {
        final aTime = a.lastMessage?.timestamp ?? DateTime(2000);
        final bTime = b.lastMessage?.timestamp ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
    return list;
  }

  @override
  Stream<Conversation?> watchConversation(String conversationId) async* {
    if (!_conversations.containsKey(conversationId)) {
      await _refreshConversationDetail(conversationId);
    }
    yield _conversations[conversationId];
    yield* _changes.stream.map((_) => _conversations[conversationId]);
  }

  Future<void> _refreshConversationDetail(String conversationId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.chatConversationDetail(conversationId),
      );
      final conversation = _conversationFromJson(response.data!);
      _conversations[conversation.id] = conversation;
    } catch (_) {
      // Leave uncached — the next watch/notify cycle retries.
    }
  }

  @override
  Conversation? conversationById(String conversationId) =>
      _conversations[conversationId];

  @override
  Future<List<ChatParticipant>> getContacts(ChatParticipant currentUser) async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.chatContacts,
    );
    return (response.data ?? const [])
        .map((raw) => chatParticipantFromJson(raw as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Conversation> createDirectConversation({
    required ChatParticipant currentUser,
    required ChatParticipant other,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chatDirectConversation,
      data: {'other_user_id': int.parse(other.id)},
    );
    final conversation = _conversationFromJson(response.data!);
    _conversations[conversation.id] = conversation;
    _notify();
    return conversation;
  }

  @override
  Future<Conversation> createGroupConversation({
    required String title,
    required ChatParticipant createdBy,
    required List<ChatParticipant> members,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chatGroupConversation,
      data: {
        'title': title,
        'member_ids': members.map((m) => int.parse(m.id)).toList(),
      },
    );
    final conversation = _conversationFromJson(response.data!);
    _conversations[conversation.id] = conversation;
    _notify();
    return conversation;
  }

  @override
  Future<void> addMembers(
    String conversationId,
    List<ChatParticipant> members,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chatMembers(conversationId),
      data: {'member_ids': members.map((m) => int.parse(m.id)).toList()},
    );
    _conversations[conversationId] = _conversationFromJson(response.data!);
    _notify();
  }

  @override
  Future<void> removeMember(String conversationId, String memberId) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiConstants.chatMember(conversationId, memberId),
    );
    _conversations[conversationId] = _conversationFromJson(response.data!);
    _notify();
  }

  @override
  Future<void> setMuted(String conversationId, bool isMuted) async {
    await _apiClient.patch<void>(
      ApiConstants.chatMute(conversationId),
      data: {'is_muted': isMuted},
    );
    final current = _conversations[conversationId];
    if (current != null) {
      _conversations[conversationId] = current.copyWith(isMuted: isMuted);
      _notify();
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await _apiClient.delete<void>(
      ApiConstants.chatConversationDetail(conversationId),
    );
    _conversations.remove(conversationId);
    _messages.remove(conversationId);
    _media.remove(conversationId);
    _notify();
  }

  // ==================== messages ====================

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) async* {
    yield await _refreshMessages(conversationId);
    yield* _changes.stream.map(
      (_) =>
          List<ChatMessage>.unmodifiable(_messages[conversationId] ?? const []),
    );
  }

  Future<List<ChatMessage>> _refreshMessages(String conversationId) async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.chatMessages(conversationId),
    );
    final list = (response.data ?? const [])
        .map((raw) => _messageFromJson(raw as Map<String, dynamic>))
        .toList();
    _messages[conversationId] = list;
    unawaited(_refreshMedia(conversationId));
    return List.unmodifiable(list);
  }

  Future<void> _refreshMedia(String conversationId) async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiConstants.chatMedia(conversationId),
      );
      _media[conversationId] = (response.data ?? const [])
          .map((raw) => _attachmentFromJson(raw as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // mediaFor() falls back to deriving from cached messages below.
    }
  }

  @override
  List<MessageAttachment> mediaFor(
    String conversationId, {
    AttachmentKind? kind,
  }) {
    final attachments =
        _media[conversationId] ??
        (_messages[conversationId] ?? const [])
            .expand((m) => m.attachments)
            .toList()
            .reversed
            .toList();
    if (kind == null) return attachments;
    return attachments.where((a) => a.kind == kind).toList();
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required ChatParticipant sender,
    String? text,
    ChatMessageType type = ChatMessageType.text,
    List<MessageAttachment> attachments = const [],
    String? replyToMessageId,
  }) async {
    ReplyPreview? replyTo;
    if (replyToMessageId != null) {
      for (final candidate
          in _messages[conversationId] ?? const <ChatMessage>[]) {
        if (candidate.id == replyToMessageId) {
          replyTo = ReplyPreview(
            id: candidate.id,
            senderName: candidate.senderName,
            type: candidate.type,
            text: candidate.text,
            isDeleted: candidate.isDeleted,
          );
          break;
        }
      }
    }

    // Optimistic local echo so the composer feels instant; swapped for the
    // server's copy (real id, decrypted-on-read text, uploaded URLs) once
    // the request resolves.
    final tempId = 'pending-${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = ChatMessage(
      id: tempId,
      conversationId: conversationId,
      senderId: sender.id,
      senderName: sender.name,
      timestamp: DateTime.now(),
      isFromMe: true,
      type: type,
      text: text,
      attachments: attachments,
      status: MessageDeliveryStatus.sending,
      replyTo: replyTo,
    );
    final list = _messages.putIfAbsent(conversationId, () => []);
    list.add(optimistic);
    _bumpLastMessage(conversationId, optimistic);
    _notify();

    try {
      final formData = dio.FormData.fromMap({
        'type': chatMessageTypeToWire(type),
        if (text != null && text.isNotEmpty) 'text': text,
        if (replyToMessageId != null) 'reply_to_message_id': replyToMessageId,
        if (attachments.isNotEmpty)
          'files': await Future.wait(
            attachments
                .where((a) => a.localPath != null)
                .map(
                  (a) => dio.MultipartFile.fromFile(
                    a.localPath!,
                    filename: a.fileName,
                  ),
                ),
          ),
      });
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.chatMessages(conversationId),
        data: formData,
      );
      final sent = _messageFromJson(response.data!);
      final index = list.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        list[index] = sent;
      } else {
        list.add(sent);
      }
      _bumpLastMessage(conversationId, sent);
      _notify();
      return sent;
    } catch (_) {
      final index = list.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        list[index] = optimistic.copyWith(status: MessageDeliveryStatus.failed);
        _notify();
      }
      rethrow;
    }
  }

  @override
  Future<void> unsendMessage(String conversationId, String messageId) async {
    final list = _messages[conversationId];
    final index = list?.indexWhere((m) => m.id == messageId) ?? -1;
    final previous = index != -1 ? list![index] : null;
    if (list != null && index != -1) {
      list[index] = list[index].copyWith(isDeleted: true);
      if (_conversations[conversationId]?.lastMessage?.id == messageId) {
        _bumpLastMessage(conversationId, list[index]);
      }
      _notify();
    }
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        ApiConstants.chatMessage(conversationId, messageId),
      );
      final updated = _messageFromJson(response.data!);
      final freshIndex =
          _messages[conversationId]?.indexWhere((m) => m.id == messageId) ?? -1;
      if (freshIndex != -1) {
        _messages[conversationId]![freshIndex] = updated;
        if (_conversations[conversationId]?.lastMessage?.id == messageId) {
          _bumpLastMessage(conversationId, updated);
        }
        _notify();
      }
    } catch (_) {
      // Revert the optimistic delete if the server rejected it (e.g. no
      // longer the sender's message, or already offline-queued too late).
      if (list != null && index != -1 && previous != null) {
        list[index] = previous;
        _notify();
      }
      rethrow;
    }
  }

  void _bumpLastMessage(String conversationId, ChatMessage message) {
    final conversation = _conversations[conversationId];
    if (conversation == null) return;
    _conversations[conversationId] = conversation.copyWith(
      lastMessage: message,
    );
  }

  @override
  Future<void> markRead(String conversationId, String userId) async {
    await _apiClient.put<void>(ApiConstants.chatRead(conversationId));
    final conversation = _conversations[conversationId];
    if (conversation != null && conversation.unreadCount != 0) {
      _conversations[conversationId] = conversation.copyWith(unreadCount: 0);
      _notify();
    }
  }

  @override
  Future<List<ChatMessage>> searchMessages(
    String conversationId,
    String query,
  ) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.chatSearch(conversationId),
      queryParameters: {'q': trimmed},
    );
    return (response.data ?? const [])
        .map((raw) => _messageFromJson(raw as Map<String, dynamic>))
        .toList();
  }

  // ==================== socket events ====================

  void _handleSocketEvent(Map<String, dynamic> event) {
    switch (event['type'] as String?) {
      case 'message:new':
        _onMessageNew(event);
      case 'message:deleted':
        _onMessageDeleted(event);
      case 'message:read':
        _onMessageRead(event);
      case 'conversation:updated':
        _onConversationUpdated(event);
    }
  }

  void _onMessageNew(Map<String, dynamic> event) {
    final conversationId = event['conversation_id'].toString();
    final message = _messageFromJson(event['message'] as Map<String, dynamic>);
    final list = _messages.putIfAbsent(conversationId, () => []);
    if (list.any((m) => m.id == message.id)) return;
    list.add(message);
    _bumpLastMessage(conversationId, message);
    final conversation = _conversations[conversationId];
    if (conversation != null) {
      _conversations[conversationId] = conversation.copyWith(
        unreadCount: conversation.unreadCount + 1,
      );
    }
    _notify();
  }

  void _onMessageDeleted(Map<String, dynamic> event) {
    final conversationId = event['conversation_id'].toString();
    final updated = _messageFromJson(event['message'] as Map<String, dynamic>);
    final list = _messages[conversationId];
    if (list != null) {
      final index = list.indexWhere((m) => m.id == updated.id);
      if (index != -1) list[index] = updated;
    }
    if (_conversations[conversationId]?.lastMessage?.id == updated.id) {
      _bumpLastMessage(conversationId, updated);
    }
    _notify();
  }

  void _onMessageRead(Map<String, dynamic> event) {
    // A peer just read our messages in this conversation — refetch the
    // thread so read-receipt ticks catch up rather than guessing which
    // messages crossed the read line locally.
    final conversationId = event['conversation_id'].toString();
    if (_messages.containsKey(conversationId)) {
      unawaited(_refreshMessages(conversationId).then((_) => _notify()));
    }
  }

  void _onConversationUpdated(Map<String, dynamic> event) {
    final conversation = _conversationFromJson(
      event['conversation'] as Map<String, dynamic>,
    );
    _conversations[conversation.id] = conversation;
    _notify();
  }

  // ==================== JSON -> model ====================

  MessageAttachment _attachmentFromJson(Map<String, dynamic> json) {
    final durationMs = json['duration_ms'] as int?;
    return MessageAttachment(
      id: json['id'].toString(),
      kind: chatAttachmentKindFromWire(json['kind'] as String),
      fileName: json['file_name'] as String,
      remoteUrl: json['url'] as String?,
      fileSizeBytes: json['size_bytes'] as int? ?? 0,
      mimeType: json['mime_type'] as String?,
      duration: durationMs != null ? Duration(milliseconds: durationMs) : null,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  ChatMessage _messageFromJson(Map<String, dynamic> json) {
    final senderId = json['sender_id'] as String;
    final type = chatMessageTypeFromWire(json['type'] as String);
    CallLogInfo? callLog;
    if (type == ChatMessageType.callLog) {
      callLog = CallLogInfo(
        isVideo: json['call_is_video'] as bool? ?? false,
        outcome: chatCallOutcomeFromWire(json['call_outcome'] as String?),
        isOutgoing: senderId == currentUserId,
        duration: Duration(seconds: json['call_duration_seconds'] as int? ?? 0),
      );
    }
    return ChatMessage(
      id: json['id'].toString(),
      conversationId: json['conversation_id'].toString(),
      senderId: senderId,
      senderName: json['sender_name'] as String,
      timestamp: DateTime.parse(json['created_at'] as String).toLocal(),
      isFromMe: senderId == currentUserId,
      type: type,
      text: json['text'] as String?,
      attachments: (json['attachments'] as List<dynamic>? ?? const [])
          .map((raw) => _attachmentFromJson(raw as Map<String, dynamic>))
          .toList(),
      status: chatStatusFromWire(json['status'] as String),
      callLog: callLog,
      replyTo: chatReplyPreviewFromJson(
        json['reply_to'] as Map<String, dynamic>?,
      ),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Conversation _conversationFromJson(Map<String, dynamic> json) {
    final lastMessageJson = json['last_message'] as Map<String, dynamic>?;
    return Conversation(
      id: json['id'].toString(),
      isGroup: json['is_group'] as bool,
      participants: (json['participants'] as List<dynamic>)
          .map((raw) => chatParticipantFromJson(raw as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String?,
      avatarColor: chatColorFromHex(json['avatar_color'] as String?),
      lastMessage: lastMessageJson != null
          ? _messageFromJson(lastMessageJson)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      createdBy: json['created_by'] as String?,
      isMuted: json['is_muted'] as bool? ?? false,
    );
  }
}
