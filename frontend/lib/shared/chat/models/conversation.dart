import 'package:flutter/material.dart';

import 'chat_message.dart';
import 'chat_participant.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.isGroup,
    required this.participants,
    this.title,
    this.avatarColor = const Color(0xFFCCFBF1),
    this.lastMessage,
    this.unreadCount = 0,
    this.createdBy,
    this.isMuted = false,
  });

  final String id;
  final bool isGroup;

  /// All participants, including the current device user.
  final List<ChatParticipant> participants;

  /// Required for groups; ignored (derived) for 1:1 chats.
  final String? title;
  final Color avatarColor;
  final ChatMessage? lastMessage;
  final int unreadCount;

  /// Participant id of whoever created the group — only they (or an
  /// "admin" role participant) may remove other members.
  final String? createdBy;

  /// When true, this conversation's notifications are silenced. Purely
  /// local UI state today (no push notifications exist yet), but the flag
  /// still drives the muted badge in the inbox/app bar.
  final bool isMuted;

  /// The name shown in lists/app bars: the group title, or — for a 1:1
  /// chat — the other participant's name.
  String displayTitle(String currentUserId) {
    if (isGroup) return title ?? 'Group chat';
    final other = participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => participants.first,
    );
    return other.name;
  }

  ChatParticipant? otherParticipant(String currentUserId) {
    if (isGroup) return null;
    for (final p in participants) {
      if (p.id != currentUserId) return p;
    }
    return null;
  }

  Conversation copyWith({
    List<ChatParticipant>? participants,
    ChatMessage? lastMessage,
    int? unreadCount,
    String? title,
    bool? isMuted,
  }) {
    return Conversation(
      id: id,
      isGroup: isGroup,
      participants: participants ?? this.participants,
      title: title ?? this.title,
      avatarColor: avatarColor,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdBy: createdBy,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}
