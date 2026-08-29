import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_profile_model.dart';

/// Wrap of specialization chips — first/primary one filled, rest
/// outlined. Styled as a card to match [ElderlyHealthConditionCard].
class CaregiverSpecializationsSection extends StatelessWidget {
  const CaregiverSpecializationsSection({
    required this.specializations,
    super.key,
  });

  final List<SpecializationTag> specializations;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: AppColors.primaryLight),
              const SizedBox(width: 12),
              Text(
                'Specializations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in specializations)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: tag.isPrimary
                        ? AppColors.primaryContainerLight
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: tag.isPrimary
                        ? null
                        : Border.all(color: AppColors.outlineLight),
                  ),
                  child: Text(
                    tag.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: tag.isPrimary
                          ? AppColors.onPrimaryContainerLight
                          : AppColors.onSurfaceVariantLight,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
