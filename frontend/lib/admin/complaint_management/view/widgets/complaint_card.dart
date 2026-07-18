import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/complaint_model.dart';

/// Card for a single complaint. Built with plain Rows/Expanded (not
/// GridView) for the 2x2 detail grid, so text never gets clipped by a
/// fixed grid-item height on narrow screens.
class ComplaintCard extends StatelessWidget {
  const ComplaintCard({
    required this.complaint,
    this.onView,
    this.onResolve,
    super.key,
  });

  final Complaint complaint;
  final VoidCallback? onView;
  final VoidCallback? onResolve;

  Color get _statusDotColor {
    switch (complaint.status) {
      case ComplaintStatus.open:
        return AppColors.outlineLight;
      case ComplaintStatus.inProgress:
        return AppColors.secondaryLight;
      case ComplaintStatus.resolved:
        return AppColors.primaryLight;
      case ComplaintStatus.escalated:
        return AppColors.errorLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isResolved = complaint.status == ComplaintStatus.resolved;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            complaint.id,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryLight,
            ),
          ),
          Text(
            _formatDateTime(complaint.reportedAt),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariantLight,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariantLight.withValues(alpha: 0.3),
                ),
                bottom: BorderSide(
                  color: AppColors.outlineVariantLight.withValues(alpha: 0.3),
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DetailField(
                        label: 'Reporter',
                        value: complaint.reporterName,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DetailField(
                        label: 'Against',
                        value: complaint.againstName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DetailField(
                        label: 'Category',
                        value: complaint.category,
                      ),
                    ),
                    Expanded(
                      child: _DetailField(
                        label: 'Status',
                        value: complaint.statusDetail,
                        dotColor: _statusDotColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: onView,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryLight,
                      side: BorderSide(color: AppColors.outlineLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isResolved ? null : onResolve,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.onPrimaryLight,
                      disabledBackgroundColor:
                      AppColors.surfaceContainerHighLight,
                      disabledForegroundColor:
                      AppColors.onSurfaceVariantLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isResolved ? 'Resolved' : 'Resolve',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDateTime(DateTime date) {
    final hour24 = date.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '${_months[date.month - 1]} ${date.day}, ${date.year} • '
        '$hour12:$minute $period';
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.label,
    required this.value,
    this.dotColor,
  });

  final String label;
  final String value;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: AppColors.onSurfaceVariantLight,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}