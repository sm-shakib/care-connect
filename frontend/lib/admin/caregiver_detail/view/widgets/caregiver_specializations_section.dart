import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_profile_model.dart';

/// Wrap of specialization chips — first/primary one filled, rest
/// outlined.
class CaregiverSpecializationsSection extends StatelessWidget {
  const CaregiverSpecializationsSection({
    required this.specializations,
    super.key,
  });

  final List<SpecializationTag> specializations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specializations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceLight,
          ),
        ),
        const SizedBox(height: 12),
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
    );
  }
}