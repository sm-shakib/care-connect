class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
    this.senderName,
  });

  final String id;
  final String text;
  final DateTime timestamp;

  /// True when sent by the caregiver (the current user of this app).
  final bool isFromMe;
  final String? senderName;
}