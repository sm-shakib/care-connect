import 'package:flutter/material.dart';

import '../../patient_chat/patient_chat.dart';
import '../data/chat_thread_dummy_data.dart';
import '../widgets/chat_thread_tile.dart';

class CaregiverChatListPage extends StatelessWidget {
  const CaregiverChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final threads = buildChatThreadDummyData()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (threads.isEmpty) {
      return Center(
        child: Text(
          'No conversations yet.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: threads.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: colorScheme.outlineVariant.withValues(alpha: 0.25),
      ),
      itemBuilder: (context, index) {
        final thread = threads[index];
        return ChatThreadTile(
          thread: thread,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientChatPage(
                  contactName: thread.name,
                  isGroup: thread.isGroup,
                ),
              ),
            );
          },
        );
      },
    );
  }
}