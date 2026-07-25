import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/elderly_profile_model.dart';

/// "Recent SOS Events" section.
class RecentSosEventsSection extends StatelessWidget {
  const RecentSosEventsSection({required this.events, super.key});

  final List<SosEventSummary> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent SOS Events',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceLight,
          ),
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariantLight),
            ),
            child: Text(
              'No SOS events recorded.',
              style: TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
          )
        else
          Column(
            children: [
              for (final event in events) ...[
                _SosEventRow(event: event),
                if (event != events.last) const SizedBox(height: 8),
              ],
            ],
          ),
      ],
    );
  }
}

class _SosEventRow extends StatelessWidget {
  const _SosEventRow({required this.event});

  final SosEventSummary event;

  (Color, Color) get _statusColors {
    switch (event.status) {
      case SosEventStatus.resolved:
        return (
        AppColors.primaryFixedDimLight.withValues(alpha: 0.2),
        AppColors.onTertiaryContainerLight,
        );
      case SosEventStatus.falseAlarm:
        return (
        AppColors.surfaceContainerHighLight,
        AppColors.onSurfaceVariantLight,
        );
      case SosEventStatus.pending:
        return (AppColors.errorContainerLight, AppColors.onErrorContainerLight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusBg, statusFg) = _statusColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.errorContainerLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emergency, color: AppColors.errorLight),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.dateLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceLight,
                  ),
                ),
                Text(
                  event.timeLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariantLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.tertiaryFixedDimLight),
            ),
            child: Text(
              event.status.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: statusFg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}