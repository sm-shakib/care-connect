import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// "Schedule" card. Primary-tinted background/border, matching the
/// original design's `bg-primary-container/10` styling — the only
/// card on this screen with that treatment.
class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    required this.startDateLabel,
    required this.endDateLabel,
    required this.dailyTimingLabel,
    super.key,
  });

  final String startDateLabel;
  final String endDateLabel;
  final String dailyTimingLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainerLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryContainerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: AppColors.primaryLight),
              const SizedBox(width: 8),
              Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Date',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariantLight,
                      ),
                    ),
                    Text(
                      startDateLabel,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onSurfaceLight,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Date',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariantLight,
                      ),
                    ),
                    Text(
                      endDateLabel,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onSurfaceLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.primaryContainerLight.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Timing',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariantLight,
                  ),
                ),
                Text(
                  dailyTimingLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}