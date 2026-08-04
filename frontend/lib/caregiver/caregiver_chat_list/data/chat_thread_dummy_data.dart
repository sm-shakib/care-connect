import '../models/chat_thread.dart';

// TODO: replace with a real chat repository once the messaging API exists.
List<ChatThread> buildChatThreadDummyData() {
  final now = DateTime.now();

  return [
    ChatThread(
      id: 't1',
      name: 'Abdul Karim',
      lastMessage: 'That is wonderful to hear, thank you for the update.',
      timestamp: now.subtract(const Duration(minutes: 20)),
      isGroup: false,
      unreadCount: 0,
    ),
    ChatThread(
      id: 't2',
      name: 'Abdul Karim - Family Group',
      lastMessage: "Ayesha: Perfect, I will keep the meds ready by then.",
      timestamp: now.subtract(const Duration(hours: 1, minutes: 5)),
      isGroup: true,
    ),
    // ChatThread(
    //   id: 't3',
    //   name: 'Arthur Miller',
    //   lastMessage: 'Blood pressure logged at 120/80, all stable.',
    //   timestamp: now.subtract(const Duration(hours: 3)),
    //   isGroup: false,
    // ),
    // ChatThread(
    //   id: 't4',
    //   name: 'Arthur Miller — Family Group',
    //   lastMessage: 'Sarah: Can someone confirm the physio session time?',
    //   timestamp: now.subtract(const Duration(hours: 5)),
    //   isGroup: true,
    //   unreadCount: 1,
    // ),
    // ChatThread(
    //   id: 't5',
    //   name: 'Rose Dawson',
    //   lastMessage: 'Reached her hydration goal today!',
    //   timestamp: now.subtract(const Duration(days: 1)),
    //   isGroup: false,
    // ),
    // ChatThread(
    //   id: 't6',
    //   name: 'John Watson — Family Group',
    //   lastMessage: 'You: Physical therapy went well this afternoon.',
    //   timestamp: now.subtract(const Duration(days: 1, hours: 2)),
    //   isGroup: true,
    // ),
  ];
}