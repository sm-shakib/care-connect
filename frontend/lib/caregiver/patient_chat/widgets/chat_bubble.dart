import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend/theme/app_colors.dart';

import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeLabel = DateFormat('h:mm a').format(message.timestamp);

    return Align(
      alignment: message.isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment:
              message.isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isFromMe && message.senderName != null) ...[
              _ChatAvatar(name: message.senderName!),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    message.isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!message.isFromMe && message.senderName != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        message.senderName!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  Container(
                    constraints:
                        BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.68),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: message.isFromMe
                          ? AppColors.darkTeal
                          : colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(message.isFromMe ? 16 : 4),
                        bottomRight: Radius.circular(message.isFromMe ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          message.isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            fontSize: 15,
                            color: message.isFromMe ? Colors.white : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: message.isFromMe
                                ? Colors.white.withValues(alpha: 0.7)
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (message.isFromMe) ...[
              const SizedBox(width: 8),
              _ChatAvatar(name: 'You'),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join()
        .toUpperCase();

    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.paleMint,
      child: Text(
        initials.isEmpty ? '•' : initials,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTeal,
        ),
      ),
    );
  }
}