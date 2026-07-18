import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/complaint_detail_model.dart';

/// Top status card: complaint ID + a status badge whose color reflects
/// [ComplaintDetail.status] (not just a static "Pending Review" pill
/// like the original mockup), plus the filed date.
class ComplaintStatusCard extends StatelessWidget {
  const ComplaintStatusCard({required this.complaint, super.key});

  final ComplaintDetail complaint;

  (Color, Color) get _badgeColors {
    switch (complaint.status) {
      case ComplaintDetailStatus.open:
        return (
        AppColors.surfaceContainerHighLight,
        AppColors.onSurfaceVariantLight,
        );
      case ComplaintDetailStatus.inProgress:
        return (
        AppColors.secondaryContainerLight,
        AppColors.onSecondaryContainerLight,
        );
      case ComplaintDetailStatus.resolved:
        return (
        AppColors.primaryContainerLight,
        AppColors.onPrimaryContainerLight,
        );
      case ComplaintDetailStatus.escalated:
        return (AppColors.errorContainerLight, AppColors.onErrorContainerLight);
    }
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  @override
  Widget build(BuildContext context) {
    final (badgeBg, badgeFg) = _badgeColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complaint ID',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariantLight,
                      ),
                    ),
                    Text(
                      '#${complaint.id}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  complaint.statusDetail,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: badgeFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: AppColors.onSurfaceVariantLight,
              ),
              const SizedBox(width: 8),
              Text(
                'Filed on ${_formatDate(complaint.filedDate)}',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariantLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}