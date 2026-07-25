import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:intl/intl.dart';

import '../models/medication_reminder.dart';

class MedicationReminderTile extends StatelessWidget {
  const MedicationReminderTile({
    super.key,
    required this.medication,
    required this.onMarkTaken,
  });

  final MedicationReminder medication;
  final VoidCallback onMarkTaken;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scheduledLabel = DateFormat('h:mm a').format(medication.scheduledTime);

    switch (medication.status) {
      case MedicationStatus.taken:
        final takenLabel = medication.takenAt != null
            ? DateFormat('h:mm a').format(medication.takenAt!)
            : scheduledLabel;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.tertiaryContainer.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                child: Icon(Icons.check_circle, color: colorScheme.onTertiaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    Text(
                      'Taken at $takenLabel',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                'DONE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
        );

      case MedicationStatus.dueNow:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.15),
                //child: Icon(Icons.medication, color: colorScheme.primary),
                child: Icon(Icons.medication, color: AppColors.darkTeal),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    Text(
                      'Scheduled: $scheduledLabel',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onMarkTaken,
                style: ElevatedButton.styleFrom(
                  //backgroundColor: colorScheme.primary,
                  backgroundColor: AppColors.darkTeal,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Mark Taken', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );

      case MedicationStatus.upcoming:
        return Opacity(
          opacity: 0.55,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  //child: Icon(Icons.schedule, color: colorScheme.outline),
                  child: Icon(Icons.schedule, color: AppColors.darkTeal),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      Text(
                        'Scheduled: $scheduledLabel',
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}