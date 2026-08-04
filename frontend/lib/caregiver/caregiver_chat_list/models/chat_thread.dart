class ChatThread {
  const ChatThread({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.isGroup,
    this.unreadCount = 0,
  });

  final String id;

  /// For a 1:1 thread, the patient's name. For a group thread, e.g.
  /// "Eleanor Rigby — Family Group" (caregiver + elder + family members).
  final String name;

  final String lastMessage;
  final DateTime timestamp;
  final bool isGroup;
  final int unreadCount;
}