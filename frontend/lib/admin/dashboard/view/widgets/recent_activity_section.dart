import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/dashboard_model.dart';

/// "Recent Activity" section: header with a History action, then a
/// list of activity rows.
class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    required this.activities,
    this.onHistoryTap,
    this.onActivityTap,
    super.key,
  });

  final List<ActivityItem> activities;
  final VoidCallback? onHistoryTap;
  final ValueChanged<ActivityItem>? onActivityTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceLight,
              ),
            ),
            TextButton(
              onPressed: onHistoryTap,
              child: Text(
                'History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (activities.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No recent activity.',
              style: TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
          )
        else
          Column(
            children: [
              for (final activity in activities) ...[
                _ActivityTile(
                  activity: activity,
                  onTap: () => onActivityTap?.call(activity),
                ),
                if (activity != activities.last) const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity, this.onTap});

  final ActivityItem activity;
  final VoidCallback? onTap;

  (IconData, Color, Color) get _iconStyle {
    switch (activity.type) {
      case ActivityType.caregiver:
        return (
        Icons.person_add,
        AppColors.primaryContainerLight,
        AppColors.onPrimaryContainerLight,
        );
      case ActivityType.complaint:
        return (
        Icons.report,
        AppColors.errorContainerLight,
        AppColors.onErrorContainerLight,
        );
      case ActivityType.booking:
        return (
        Icons.event,
        AppColors.tertiaryContainerLight,
        AppColors.onTertiaryContainerLight,
        );

      case ActivityType.central_fund:
        return (
        Icons.event,
        AppColors.tertiaryContainerLight,
        AppColors.onTertiaryContainerLight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, iconBg, iconFg) = _iconStyle;

    return Material(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariantLight),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconFg, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      activity.subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onSurfaceVariantLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                activity.timeAgo,
                style: TextStyle(fontSize: 14, color: AppColors.outlineLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}