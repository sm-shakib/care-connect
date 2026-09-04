import 'package:flutter/material.dart';

import '../models/call_log_info.dart';
import '../models/chat_message.dart';
import '../models/chat_participant.dart';
import '../models/message_attachment.dart';

/// Wire-format (JSON) <-> model conversions shared between
/// `RealChatRepository` and `ChatSession` — kept here (rather than as
/// private helpers inside either) since both need them and Dart privacy
/// is per-file.

ChatParticipant chatParticipantFromJson(Map<String, dynamic> json) {
  return ChatParticipant(
    id: json['id'] as String,
    name: json['name'] as String,
    role: chatRoleFromWire(json['role'] as String),
    avatarColor: chatColorFromHex(json['avatar_color'] as String?),
    isOnline: json['is_online'] as bool? ?? false,
  );
}

ChatRole chatRoleFromWire(String role) {
  switch (role) {
    case 'elderly':
      return ChatRole.elderly;
    case 'caregiver':
      return ChatRole.caregiver;
    case 'family':
      return ChatRole.family;
    default:
      return ChatRole.admin;
  }
}

AttachmentKind chatAttachmentKindFromWire(String kind) {
  switch (kind) {
    case 'image':
      return AttachmentKind.image;
    case 'video':
      return AttachmentKind.video;
    case 'voice':
      return AttachmentKind.voice;
    default:
      return AttachmentKind.document;
  }
}

ChatMessageType chatMessageTypeFromWire(String type) {
  switch (type) {
    case 'image':
      return ChatMessageType.image;
    case 'video':
      return ChatMessageType.video;
    case 'document':
      return ChatMessageType.document;
    case 'voice':
      return ChatMessageType.voice;
    case 'call_log':
      return ChatMessageType.callLog;
    default:
      return ChatMessageType.text;
  }
}

String chatMessageTypeToWire(ChatMessageType type) {
  switch (type) {
    case ChatMessageType.text:
      return 'text';
    case ChatMessageType.image:
      return 'image';
    case ChatMessageType.video:
      return 'video';
    case ChatMessageType.document:
      return 'document';
    case ChatMessageType.voice:
      return 'voice';
    case ChatMessageType.callLog:
      return 'call_log';
  }
}

MessageDeliveryStatus chatStatusFromWire(String status) {
  switch (status) {
    case 'read':
      return MessageDeliveryStatus.read;
    case 'delivered':
      return MessageDeliveryStatus.delivered;
    default:
      return MessageDeliveryStatus.sent;
  }
}

ReplyPreview? chatReplyPreviewFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return ReplyPreview(
    id: json['id'].toString(),
    senderName: json['sender_name'] as String,
    type: chatMessageTypeFromWire(json['type'] as String),
    text: json['text'] as String?,
    isDeleted: json['is_deleted'] as bool? ?? false,
  );
}

CallOutcome chatCallOutcomeFromWire(String? outcome) {
  switch (outcome) {
    case 'missed':
      return CallOutcome.missed;
    case 'declined':
      return CallOutcome.declined;
    default:
      return CallOutcome.answered;
  }
}

/// Parses a `"#RRGGBB"` hex string from the backend into a [Color],
/// falling back to the app's default participant teal when absent/invalid.
Color chatColorFromHex(String? hex) {
  const fallback = Color(0xFFCCFBF1);
  if (hex == null || hex.isEmpty) return fallback;
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return fallback;
  return Color(0xFF000000 | value);
}
