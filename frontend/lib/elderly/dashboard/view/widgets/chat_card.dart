import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/dashboard_models.dart';
import 'dashboard_card_header.dart';

/// Card previewing the most recent chat message, tappable to open the
/// full conversation.
class ChatCard extends StatelessWidget {
  const ChatCard({required this.chat, this.onTap, super.key});

  final ChatPreview? chat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: chat == null ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardCardHeader(
                icon: Icons.chat_bubble_outline,
                title: 'Chat',
              ),
              const SizedBox(height: 14),
              if (chat == null)
                Text(
                  'No messages yet.',
                  style: TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant),
                )
              else
                _ChatPreviewRow(chat: chat!),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatPreviewRow extends StatelessWidget {
  const _ChatPreviewRow({required this.chat});

  final ChatPreview chat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      chat.senderName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    chat.timeLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                chat.lastMessage,
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (chat.unreadCount > 0) ...[
          const SizedBox(width: 10),
          _UnreadBadge(count: chat.unreadCount),
        ],
        const SizedBox(width: 4),
        Icon(Icons.chevron_right, size: 26, color: colorScheme.onSurfaceVariant),
      ],
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
