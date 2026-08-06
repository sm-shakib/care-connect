import 'call_log_info.dart';
import 'message_attachment.dart';

enum ChatMessageType { text, image, document, voice, video, callLog }

enum MessageDeliveryStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.isFromMe,
    this.type = ChatMessageType.text,
    this.text,
    this.attachments = const [],
    this.status = MessageDeliveryStatus.sent,
    this.callLog,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final DateTime timestamp;

  /// True when sent by the current device user.
  final bool isFromMe;

  final ChatMessageType type;
  final String? text;
  final List<MessageAttachment> attachments;
  final MessageDeliveryStatus status;
  final CallLogInfo? callLog;

  MessageAttachment? get primaryAttachment =>
      attachments.isEmpty ? null : attachments.first;

  /// Short text used for conversation-list previews and search snippets.
  String get previewText {
    switch (type) {
      case ChatMessageType.text:
        return text ?? '';
      case ChatMessageType.image:
        return '📷 Photo';
      case ChatMessageType.video:
        return '🎥 Video';
      case ChatMessageType.document:
        return '📄 ${primaryAttachment?.fileName ?? 'Document'}';
      case ChatMessageType.voice:
        return '🎤 Voice message';
      case ChatMessageType.callLog:
        final video = callLog?.isVideo ?? false;
        return video ? '🎥 Video call' : '📞 Voice call';
    }
  }

  ChatMessage copyWith({
    MessageDeliveryStatus? status,
  }) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      timestamp: timestamp,
      isFromMe: isFromMe,
      type: type,
      text: text,
      attachments: attachments,
      status: status ?? this.status,
      callLog: callLog,
    );
  }
}
