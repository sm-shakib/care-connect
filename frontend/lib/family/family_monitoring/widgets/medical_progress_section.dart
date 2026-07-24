import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../models/medical_record.dart';

class MedicalProgressSection extends StatelessWidget {
  const MedicalProgressSection({super.key, required this.records});

  final List<MedicalRecord> records;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Medical Progress",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          const Text("No medical records available.")
        else
          ...records.map((record) => _MedicalRecordTile(record: record)),
      ],
    );
  }
}

class _MedicalRecordTile extends StatelessWidget {
  const _MedicalRecordTile({required this.record});
  final MedicalRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.deepTrustBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.paleMint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.healthStatus,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            record.date,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.outlineLight,
            ),
          ),
          const Divider(height: 20),
          Text(
            record.doctorNote,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.onSurfaceVariantLight,
            ),
          ),
        ],
      ),
    );
  }
}
