import 'call_log_info.dart';
import 'message_attachment.dart';

enum ChatMessageType { text, image, document, voice, video, callLog }

enum MessageDeliveryStatus { sending, sent, delivered, read, failed }

/// A lightweight snapshot of the message a [ChatMessage] is replying to —
/// just enough to render the quoted preview WhatsApp/Messenger-style
/// reply bubbles show, without carrying the original's full attachment
/// list or its own reply chain.
class ReplyPreview {
  const ReplyPreview({
    required this.id,
    required this.senderName,
    required this.type,
    this.text,
    this.isDeleted = false,
  });

  final String id;
  final String senderName;
  final ChatMessageType type;
  final String? text;

  /// True when the original message has since been unsent — shown as
  /// "Original message deleted" instead of its content.
  final bool isDeleted;

  /// Short label for the quoted snippet, mirroring [ChatMessage.previewText].
  String get preview {
    if (isDeleted) return 'Original message deleted';
    switch (type) {
      case ChatMessageType.text:
        return text ?? '';
      case ChatMessageType.image:
        return '📷 Photo';
      case ChatMessageType.video:
        return '🎥 Video';
      case ChatMessageType.document:
        return '📄 Document';
      case ChatMessageType.voice:
        return '🎤 Voice message';
      case ChatMessageType.callLog:
        return '📞 Call';
    }
  }
}

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
    this.replyTo,
    this.isDeleted = false,
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

  /// Set when this message is a reply to another one in the conversation.
  final ReplyPreview? replyTo;

  /// True once the sender has "unsent" this message — its content is
  /// already stripped by the backend, so this just switches the bubble to
  /// a "This message was unsent" placeholder.
  final bool isDeleted;

  MessageAttachment? get primaryAttachment =>
      attachments.isEmpty ? null : attachments.first;

  /// Short text used for conversation-list previews and search snippets.
  String get previewText {
    if (isDeleted) return 'This message was unsent';
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
    bool? isDeleted,
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
      replyTo: replyTo,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
