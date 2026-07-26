import '../models/chat_message.dart';

// TODO: replace with a real chat repository / socket connection.
List<ChatMessage> buildChatDummyData() {
  final now = DateTime.now();
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
    // ChatMessage(
    //   id: 'c4',
    //   text: 'Also wanted to flag — the 1:00 PM dose is coming up shortly.',
    //   timestamp: now.subtract(const Duration(minutes: 20)),
    //   isFromMe: false,
    // ),
  ];
}