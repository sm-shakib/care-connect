import 'package:flutter/material.dart';

/// A single row inside [EditRemindersView]'s sections: a title/subtitle
/// pair plus edit and delete actions. Deleting asks for confirmation.
class ReminderEditTile extends StatelessWidget {
  const ReminderEditTile({
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
    this.leadingIcon,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData? leadingIcon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, color: colorScheme.secondary),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colorScheme.onSurfaceVariant, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () => _confirmDelete(context, title: title, onConfirm: onDelete),
          ),
        ],
      ),
    );
  }
}

void _confirmDelete(
  BuildContext context, {
  required String title,
  required VoidCallback onConfirm,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete this reminder?'),
      content: Text('This will remove "$title" from the care plan.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(dialogContext).pop();
          },
          child: Text('Delete', style: TextStyle(color: Theme.of(dialogContext).colorScheme.error)),
        ),
      ],
    ),
  );
}
