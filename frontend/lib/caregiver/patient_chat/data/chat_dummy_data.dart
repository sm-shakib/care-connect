import '../models/chat_message.dart';

// TODO: replace with a real chat repository / socket connection.
List<ChatMessage> buildChatDummyData({required bool isGroup}) {
  final now = DateTime.now();
  if (!isGroup) {
    return [
      ChatMessage(
        id: 'c1',
        text: 'Good morning! Just checking in on how the walk went today.',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 10)),
        isFromMe: true,
      ),
      ChatMessage(
        id: 'c2',
        text: 'I did great, finished a 20 minute walk and heart rate stayed stable.',
        timestamp: now.subtract(const Duration(hours: 3)),
        isFromMe: false,
      ),
      ChatMessage(
        id: 'c3',
        text: 'That is wonderful to hear, thank you for the update.',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 55)),
        isFromMe: true,
      ),
    ];
  }

  return [
    ChatMessage(
      id: 'g1',
      text: 'Good morning everyone, I finished the morning walk.',
      timestamp: now.subtract(const Duration(hours: 3, minutes: 40)),
      isFromMe: false,
      senderName: 'Abdul Karim',
    ),
    ChatMessage(
      id: 'g2',
      text: 'Great. Please make sure lunch is after the blood pressure check.',
      timestamp: now.subtract(const Duration(hours: 3, minutes: 33)),
      isFromMe: true,
    ),
    ChatMessage(
      id: 'g3',
      text: 'Noted. I will share the reading once it is taken.',
      timestamp: now.subtract(const Duration(hours: 3, minutes: 28)),
      isFromMe: false,
      senderName: 'Asif (Son)',
    ),
    ChatMessage(
      id: 'g4',
      text: 'Thanks both. I will join the evening call after Maghrib.',
      timestamp: now.subtract(const Duration(hours: 3, minutes: 20)),
      isFromMe: true,
    ),
    ChatMessage(
      id: 'g5',
      text: 'Perfect, I will keep the meds ready by then.',
      timestamp: now.subtract(const Duration(hours: 3, minutes: 8)),
      isFromMe: false,
      senderName: 'Ayesha (Daughter)',
    ),
  ];
}