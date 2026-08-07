import 'package:flutter/material.dart';

/// The role a chat participant plays elsewhere in the app. Used to pick a
/// sensible default avatar color/badge and to build role-appropriate
/// contact directories (see `data/chat_directory.dart`).
enum ChatRole { elderly, caregiver, family, admin }

/// A person who can appear in a conversation — either the current device
/// user or another party. There is no auth/session layer in this app yet,
/// so "who am I" is resolved via `ChatDirectory.currentUserFor(role)`
/// rather than a real logged-in identity.
class ChatParticipant {
  const ChatParticipant({
    required this.id,
    required this.name,
    required this.role,
    this.avatarColor = const Color(0xFF2DD4BF),
    this.isOnline = false,
  });

  final String id;
  final String name;
  final ChatRole role;
  final Color avatarColor;
  final bool isOnline;

  String get initials {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0]).join().toUpperCase();
  }

  @override
  bool operator ==(Object other) => other is ChatParticipant && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
