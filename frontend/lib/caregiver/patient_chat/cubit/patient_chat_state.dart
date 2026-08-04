part of 'patient_chat_cubit.dart';

class PatientChatState extends Equatable {
  const PatientChatState({
    required this.contactName,
    this.isGroup = false,
    this.messages = const [],
  });

  final String contactName;
  final bool isGroup;
  final List<ChatMessage> messages;

  PatientChatState copyWith({
    bool? isGroup,
    List<ChatMessage>? messages,
  }) {
    return PatientChatState(
      contactName: contactName,
      isGroup: isGroup ?? this.isGroup,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [contactName, isGroup, messages];
}