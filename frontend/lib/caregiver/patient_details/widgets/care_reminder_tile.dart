import 'package:flutter/material.dart';

import '../models/care_reminder.dart';

class CareReminderTile extends StatelessWidget {
  const CareReminderTile({super.key, required this.reminder, this.onTap});

  final CareReminder reminder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = reminder.iconColorIsError ? colorScheme.error : colorScheme.secondary;
    final accentBackground = reminder.iconColorIsError
        ? colorScheme.errorContainer.withValues(alpha: 0.25)
        : colorScheme.secondaryContainer.withValues(alpha: 0.2);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(reminder.icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  Text(
                    reminder.subtitle,
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.outlineVariant),
          ],
        ),
      ),
    );
  }
}