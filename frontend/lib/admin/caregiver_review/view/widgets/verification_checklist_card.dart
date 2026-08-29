import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_application_model.dart';

/// "Verification Status" card: a completion badge plus a checklist of
/// verified items (each with a clickable filled green/primary check bullet).
class VerificationChecklistCard extends StatelessWidget {
  const VerificationChecklistCard({
    required this.checklist,
    required this.completedCount,
    this.onToggle,
    super.key,
  });

  final List<ChecklistItem> checklist;
  final int completedCount;
  final ValueChanged<ChecklistItem>? onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariantLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
                'Verification Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceLight,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$completedCount/${checklist.length} Complete',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              for (final item in checklist) ...[
                _ChecklistRow(
                  item: item,
                  onTap: () => onToggle?.call(item),
                ),
                if (item != checklist.last) const SizedBox(height: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item, this.onTap});

  final ChecklistItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
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
                style: TextStyle(fontSize: 16, color: AppColors.onSurfaceLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
