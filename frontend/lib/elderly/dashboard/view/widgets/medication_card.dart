import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/dashboard_models.dart';
import 'dashboard_card_header.dart';

/// Card summarizing today's medication schedule on the elderly dashboard.
class MedicationCard extends StatelessWidget {
  const MedicationCard({
    required this.medications,
    this.onMarkTaken,
    this.onViewAll,
    super.key,
  });

  final List<Medication> medications;
  final ValueChanged<Medication>? onMarkTaken;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardCardHeader(
            icon: Icons.medication_outlined,
            title: "Today's Medication",
            trailingLabel: 'View all',
            onTrailingTap: onViewAll,
          ),
          const SizedBox(height: 14),
          if (medications.isEmpty)
            Text(
              'No medications scheduled today.',
              style: TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant),
            )
          else
            ...medications.map(
              (medication) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MedicationTile(
                  medication: medication,
                  onMarkTaken: onMarkTaken == null
                      ? null
                      : () => onMarkTaken!(medication),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({required this.medication, this.onMarkTaken});

  final Medication medication;
  final VoidCallback? onMarkTaken;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _TimeBadge(time: medication.time),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  medication.dosage,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (medication.isTaken)
            const Icon(
              Icons.check_circle,
              color: AppColors.primaryLight,
              size: 28,
            )
          else
            OutlinedButton(
              onPressed: onMarkTaken,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryLight,
                side: const BorderSide(color: AppColors.primaryLight, width: 1.4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Mark taken',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainerLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimaryContainerLight,
        ),
      ),
    );
  }
}
