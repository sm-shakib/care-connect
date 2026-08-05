import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../models/medication.dart';

class MedicationSection extends StatelessWidget {
  const MedicationSection({super.key, required this.medications});

  final List<Medication> medications;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Medication Schedule",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
        const SizedBox(height: 12),
        if (medications.isEmpty)
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
                Text("No medications scheduled for today."),
              ],
            ),
          )
        else
          ...medications.map((med) => _MedicationTile(medication: med)),
      ],
    );
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({required this.medication});
  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: medication.isTaken
            ? AppColors.paleMint
            : AppColors.surfaceContainerLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medication,
            color: medication.isTaken
                ? AppColors.primaryTeal
                : AppColors.outlineLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${medication.dosage} • ${medication.time}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariantLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            medication.isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
            color: medication.isTaken ? Colors.green : AppColors.outlineLight,
          ),
        ],
      ),
    );
  }
}
