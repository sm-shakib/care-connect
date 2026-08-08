import 'package:flutter/material.dart';
import 'package:frontend/shared/medicine/models/medicine.dart';
import 'package:frontend/shared/medicine/widgets/medicine_card.dart';

import '../../../theme/app_colors.dart';

/// Read-only medication schedule for an elder being monitored, reusing
/// the shared [MedicineCard] used across the medicine feature.
class MedicationSection extends StatelessWidget {
  const MedicationSection({super.key, required this.medications});

  final List<Medicine> medications;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medication Schedule',
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
                Text('No medications scheduled for today.'),
              ],
            ),
          )
        else
          for (final medicine in medications) ...[
            MedicineCard(medicine: medicine, showTakenStatus: true),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}
