import 'package:flutter/material.dart';
import 'package:frontend/caregiver/patient_chat/view/patient_chat_page.dart';

class FamilyChatPage extends StatelessWidget {
  const FamilyChatPage({super.key, required this.contactName});

  final String contactName;

  @override
  Widget build(BuildContext context) {
    // Reusing the existing PatientChatPage for consistency
    return PatientChatPage(contactName: contactName);
  }
}
