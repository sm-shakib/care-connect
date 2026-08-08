import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Section title with an icon on the left and an optional "+ Add" action
/// on the right. Used across the reminders/appointments/medications
/// sections of [EditRemindersView].
class RemindersSectionHeader extends StatelessWidget {
  const RemindersSectionHeader({
    required this.title,
    required this.icon,
    this.onAdd,
    super.key,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.darkTeal, size: 22),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceLight,
              ),
            ),
          ],
        ),
        if (onAdd != null)
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
            style: TextButton.styleFrom(foregroundColor: AppColors.darkTeal),
          ),
      ],
    );
  }
}
