import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend/theme/app_colors.dart';

import '../models/chat_participant.dart';
import '../models/conversation.dart';

/// One row in the shared chat inbox — adapted from the old caregiver-only
/// `ChatThreadTile`, generalized to the shared [Conversation] model.
/// Swipe left, or long-press, for mute/delete.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUser,
    this.onTap,
    this.onMuteToggle,
    this.onDelete,
  });

  final Conversation conversation;
  final ChatParticipant currentUser;
  final VoidCallback? onTap;
  final VoidCallback? onMuteToggle;
  final VoidCallback? onDelete;

  Future<bool> _confirmDelete(BuildContext context) async {
    final title = conversation.displayTitle(currentUser.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete chat?'),
        content: Text('This removes "$title" and its message history from your device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.warningRed),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _showOptions(BuildContext context) async {
    final action = await showModalBottomSheet<_TileAction>(
      context: context,
      backgroundColor: const Color(0xFFFBFEFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              if (onMuteToggle != null)
                ListTile(
                  leading: Icon(
                    conversation.isMuted ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
                    color: AppColors.darkTeal,
                  ),
                  title: Text(conversation.isMuted ? 'Unmute notifications' : 'Mute notifications'),
                  onTap: () => Navigator.pop(sheetContext, _TileAction.mute),
                ),
              if (onDelete != null)
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Theme.of(sheetContext).colorScheme.error),
                  title: const Text('Delete chat'),
                  onTap: () => Navigator.pop(sheetContext, _TileAction.delete),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (action == _TileAction.mute) {
      onMuteToggle?.call();
    } else if (action == _TileAction.delete) {
      if (await _confirmDelete(context)) onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lastMessage = conversation.lastMessage;
    final timeLabel =
        lastMessage == null ? '' : DateFormat('h:mm a').format(lastMessage.timestamp);
    final hasUnread = conversation.unreadCount > 0;
    final title = conversation.displayTitle(currentUser.id);
    final preview = lastMessage == null
        ? 'Say hello 👋'
        : conversation.isGroup
            ? '${lastMessage.isFromMe ? 'You' : lastMessage.senderName}: ${lastMessage.previewText}'
            : lastMessage.previewText;

    final tile = InkWell(
      onTap: onTap,
      onLongPress: (onMuteToggle == null && onDelete == null) ? null : () => _showOptions(context),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: conversation.avatarColor,
              child: Icon(
                conversation.isGroup ? Icons.groups : Icons.person,
                color: AppColors.darkTeal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (conversation.isMuted) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.notifications_off, size: 14, color: colorScheme.onSurfaceVariant),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasUnread ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeLabel,
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.darkTeal,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (onDelete == null) return tile;

    return Dismissible(
      key: ValueKey(conversation.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete!.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: AppColors.warningRed,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: tile,
    );
  }
}

enum _TileAction { mute, delete }
