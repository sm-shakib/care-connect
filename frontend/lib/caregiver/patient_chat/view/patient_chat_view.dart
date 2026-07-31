import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/patient_chat_cubit.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_top_bar.dart';

class PatientChatView extends StatefulWidget {
  const PatientChatView({super.key});

  @override
  State<PatientChatView> createState() => _PatientChatViewState();
}

class _PatientChatViewState extends State<PatientChatView> {
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocConsumer<PatientChatCubit, PatientChatState>(
          listener: (context, state) => _scrollToBottom(),
          builder: (context, state) {
            final cubit = context.read<PatientChatCubit>();

            return Column(
              children: [
                ChatTopBar(
                  contactName: state.contactName,
                  onCall: () {
                    // TODO: place a voice call to this contact.
                  },
                  onVideoCall: () {
                    // TODO: start a video call with this contact.
                  },
                ),
                Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) =>
                        ChatBubble(message: state.messages[index]),
                  ),
                ),
                ChatInputBar(onSend: cubit.sendMessage),
              ],
            );
          },
        ),
      ),
    );
  }
}