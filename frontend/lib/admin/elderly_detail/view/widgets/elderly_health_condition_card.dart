import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// "Health Conditions" card — free-text describing illnesses,
/// disabilities, chronic conditions, and allergies.
class ElderlyHealthConditionCard extends StatelessWidget {
  const ElderlyHealthConditionCard({required this.healthCondition, super.key});

  final String healthCondition;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainerLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tertiaryFixedDimLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: AppColors.tertiaryLight),
              const SizedBox(width: 12),
              Text(
                'Health Conditions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tertiaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            healthCondition,
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              color: AppColors.onSurfaceVariantLight,
            ),
          ),
        ],
      ),
    );
  }
}