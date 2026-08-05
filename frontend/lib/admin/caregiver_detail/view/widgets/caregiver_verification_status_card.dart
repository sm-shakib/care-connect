import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_profile_model.dart';

/// "Verification Status" card: overall Verified/Pending pill plus a
/// checklist of individually-verified items. Styled to match the
/// "Health Conditions" card pattern elsewhere in this app (tertiary
/// icon + tertiary header text, tertiary-tinted background/border) —
/// the original HTML's own comment says "Matching Health Conditions
/// Styling", so this deliberately isn't styled like the plain
/// on-surface headers used on most other cards.
///
/// NOTE: checklist item labels are placeholders until the real
/// `CaregiverDocumentType` values are available — see
/// `caregiver_detail_cubit.dart`.
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainerLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tertiaryFixedDimLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user, color: AppColors.tertiaryLight),
                  const SizedBox(width: 12),
                  Text(
                    'Verification Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tertiaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isVerified
                      ? AppColors.primaryLight
                      : AppColors.surfaceContainerHighLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.check_circle : Icons.hourglass_empty,
                      size: 16,
                      color: isVerified
                          ? AppColors.onPrimaryLight
                          : AppColors.onSurfaceVariantLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? 'Verified' : 'Pending',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isVerified
                            ? AppColors.onPrimaryLight
                            : AppColors.onSurfaceVariantLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < checklist.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 8),
              Divider(
                height: 1,
                color: AppColors.outlineVariantLight.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
            ],
            _ChecklistRow(item: checklist[i]),
          ],
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          item.label,
          style: TextStyle(fontSize: 16, color: AppColors.onSurfaceLight),
        ),
        Text(
          item.isVerified ? 'Verified' : 'Missing',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: item.isVerified
                ? AppColors.primaryLight
                : AppColors.errorLight,
          ),
        ),
      ],
    );
  }
}