import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/patient_chat_cubit.dart';
import 'patient_chat_view.dart';

class PatientChatPage extends StatelessWidget {
  const PatientChatPage({super.key, required this.contactName});

  final String contactName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientChatCubit(contactName: contactName),
      child: const PatientChatView(),
    );
  }
}