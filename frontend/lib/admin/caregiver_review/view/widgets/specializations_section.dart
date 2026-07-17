import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_application_model.dart';

/// Wrap of specialization chips. The primary specialization (first one
/// in the design) is filled with the tertiary color; the rest are
/// outlined/neutral.
class SpecializationsSection extends StatelessWidget {
  const SpecializationsSection({required this.specializations, super.key});

  final List<SpecializationTag> specializations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Specializations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryLight,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in specializations) _SpecializationChip(tag: tag),
          ],
        ),
      ],
    );
  }
}

class _SpecializationChip extends StatelessWidget {
  const _SpecializationChip({required this.tag});

  final SpecializationTag tag;

  @override
  Widget build(BuildContext context) {
    final isPrimary = tag.isPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.tertiaryContainerLight
            : AppColors.surfaceContainerHighestLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary
              ? AppColors.tertiaryLight
              : AppColors.outlineVariantLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconFor(tag.iconName),
            size: 18,
            color: isPrimary
                ? AppColors.onTertiaryContainerLight
                : AppColors.onSurfaceVariantLight,
          ),
          const SizedBox(width: 8),
          Text(
            tag.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isPrimary
                  ? AppColors.onTertiaryContainerLight
                  : AppColors.onSurfaceVariantLight,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String iconName) {
    switch (iconName) {
      case 'psychology':
        return Icons.psychology;
      case 'medical_services':
        return Icons.medical_services;
      case 'emergency':
        return Icons.emergency;
      default:
        return Icons.label_important_outline;
    }
  }
}