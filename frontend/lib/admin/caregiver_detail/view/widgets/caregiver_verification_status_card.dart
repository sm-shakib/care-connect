import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_profile_model.dart';

/// "Verification Status" card: a completion badge plus a checklist of
/// verified items.
class CaregiverVerificationStatusCard extends StatelessWidget {
  const CaregiverVerificationStatusCard({
    required this.isVerified,
    required this.checklist,
    super.key,
  });

  final bool isVerified;
  final List<VerificationChecklistItem> checklist;

  @override
  Widget build(BuildContext context) {
    final completedCount = checklist.where((item) => item.isVerified).length;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Verification Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainerLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$completedCount/${checklist.length} Complete',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...checklist.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ChecklistRow(item: item),
          )),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item});

  final VerificationChecklistItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: item.isVerified
                ? AppColors.primaryLight
                : AppColors.surfaceContainerHighLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.isVerified ? Icons.check : Icons.close,
            size: 16,
            color: item.isVerified
                ? Colors.white
                : AppColors.onSurfaceVariantLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceLight,
            ),
          ),
        ),
      ],
    );
  }
}
