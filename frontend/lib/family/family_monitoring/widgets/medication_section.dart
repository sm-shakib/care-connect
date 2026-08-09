import 'package:flutter/material.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/shared/medicine/models/medicine.dart';
import 'package:frontend/theme/app_colors.dart';

/// Read-only medication schedule for an elder being monitored, using the
/// unified list design pattern from the elderly dashboard.
class MedicationSection extends StatelessWidget {
  const MedicationSection({required this.medications, super.key});

  final List<Medicine> medications;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.medication_outlined,
                color: AppColors.primaryLight, size: 26),
            const SizedBox(width: 10),
            Text(
              context.l10n.medicineRemindersTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (medications.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1.6,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.outlineLight),
                const SizedBox(width: 12),
                Text(context.l10n.noMedicationsScheduled),
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
                for (var i = 0; i < medications.length; i++) ...[
                  _MedicationTile(medicine: medications[i]),
                  if (i != medications.length - 1)
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          _TimeBadge(time: medicine.nextReminder),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.getName(context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${medicine.dosage} ${medicine.form.label(context)}',
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (medicine.isTakenToday)
            const Icon(
              Icons.check_circle,
              color: AppColors.primaryLight,
              size: 28,
            )
          else
            Icon(
              Icons.radio_button_unchecked,
              color: colorScheme.outlineVariant,
              size: 28,
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
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimaryContainerLight,
        ),
      ),
    );
  }
}
