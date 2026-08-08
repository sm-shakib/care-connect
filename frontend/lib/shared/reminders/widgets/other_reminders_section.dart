import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../models/care_reminder.dart';

/// Read-only "Other Reminders" card, listing non-medication reminders
/// (e.g. therapy, hydration) for an elder being monitored.
class OtherRemindersSection extends StatelessWidget {
  const OtherRemindersSection({required this.reminders, super.key});

  final List<CareReminder> reminders;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.event_note, color: AppColors.primaryLight, size: 26),
            SizedBox(width: 10),
            Text(
              'Other Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (reminders.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.outlineLight),
                SizedBox(width: 12),
                Text('No other reminders set.'),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1.6,
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < reminders.length; i++) ...[
                  _ReminderTile(reminder: reminders[i]),
                  if (i != reminders.length - 1)
                    Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder});
  final CareReminder reminder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = reminder.isAttentionNeeded ? colorScheme.error : colorScheme.secondary;
    final accentBackground = reminder.isAttentionNeeded
        ? colorScheme.errorContainer.withValues(alpha: 0.25)
        : colorScheme.secondaryContainer.withValues(alpha: 0.2);

    return Padding(
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  reminder.subtitle,
                  style: TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
