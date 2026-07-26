import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/chat_dummy_data.dart';
import '../models/chat_message.dart';

part 'patient_chat_state.dart';

class PatientChatCubit extends Cubit<PatientChatState> {
  PatientChatCubit({required String contactName})
      : super(PatientChatState(contactName: contactName)) {
    loadMessages();
  }

  void loadMessages() {
    emit(state.copyWith(messages: buildChatDummyData()));
  }

  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final message = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: trimmed,
      timestamp: DateTime.now(),
      isFromMe: true,
    );
    // TODO: send the message to a real chat backend.
    emit(state.copyWith(messages: [...state.messages, message]));
  }
}