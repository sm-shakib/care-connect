import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/booking_detail_model.dart';

/// "Care Logs" section — the original HTML left this as an empty
/// `<!-- Care Logs Timeline -->` comment. Filled in here with a
/// simple check-in/check-out timeline, backed by the `checkin`/
/// `checkout` booking endpoints already in the ER diagram.
class CareLogsSection extends StatelessWidget {
  const CareLogsSection({required this.logs, super.key});

  final List<CareLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Care Logs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceLight,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (logs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariantLight),
            ),
            child: Text(
              'No care activity logged yet.',
              style: TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowestLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariantLight),
            ),
            child: Column(
              children: [
                for (var i = 0; i < logs.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _CareLogRow(entry: logs[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _CareLogRow extends StatelessWidget {
  const _CareLogRow({required this.entry});

  final CareLogEntry entry;

  IconData get _icon {
    switch (entry.iconName) {
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      default:
        return Icons.event_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryContainerLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _icon,
            size: 18,
            color: AppColors.onPrimaryContainerLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            entry.label,
            style: TextStyle(fontSize: 16, color: AppColors.onSurfaceLight),
          ),
        ),
        Text(
          entry.timeLabel,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariantLight,
          ),
        ),
      ],
    );
  }
}