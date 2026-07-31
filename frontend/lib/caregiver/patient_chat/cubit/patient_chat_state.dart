part of 'patient_chat_cubit.dart';

class PatientChatState extends Equatable {
  const PatientChatState({
    required this.contactName,
    this.messages = const [],
  });

  final String contactName;
  final List<ChatMessage> messages;

  PatientChatState copyWith({
    List<ChatMessage>? messages,
  }) {
    return PatientChatState(
      contactName: contactName,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [contactName, messages];
}