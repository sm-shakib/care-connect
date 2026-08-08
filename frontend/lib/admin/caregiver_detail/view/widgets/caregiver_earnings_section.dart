import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_profile_model.dart';

/// "Earnings" section. Shows the total amount earned and a list of
/// recent earnings per booking.
class CaregiverEarningsSection extends StatelessWidget {
  const CaregiverEarningsSection({
    required this.profile,
    this.onViewStatements,
    this.onRetryPayout,
    super.key,
  });

  final CaregiverProfile profile;
  final VoidCallback? onViewStatements;
  final ValueChanged<Payout>? onRetryPayout;

  static String _formatAmount(double value) {
    final digits = value.toStringAsFixed(2);
    final parts = digits.split('.');
    final whole = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      final remaining = whole.length - i;
      if (i > 0 && remaining % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    return '${buffer.toString()}.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earnings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceLight,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.payments,
                label: 'Total Earned',
                value: 'TK${_formatAmount(profile.totalEarned)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                icon: Icons.calendar_month,
                label: 'This Month',
                value: 'TK${_formatAmount(profile.thisMonthAmount)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        /*Text(
          'Recent Earnings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceLight,
          ),
        ),
        const SizedBox(height: 8),
        if (profile.recentPayouts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariantLight),
            ),
            child: Text(
              'No earnings yet.',
              style: TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
          )
        else
          Column(
            children: [
              for (final payout in profile.recentPayouts) ...[
                _PayoutRow(
                  payout: payout,
                  onRetry: () => onRetryPayout?.call(payout),
                ),
                if (payout != profile.recentPayouts.last)
                  const SizedBox(height: 8),
              ],
            ],
          ),*/
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryLight),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariantLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PayoutRow extends StatelessWidget {
  const _PayoutRow({required this.payout, this.onRetry});

  final Payout payout;
  final VoidCallback? onRetry;

  (IconData, Color, Color) get _iconStyle {
    switch (payout.status) {
      case PayoutStatus.completed:
        return (
          Icons.check,
          AppColors.primaryContainerLight,
          AppColors.onPrimaryContainerLight,
        );
      case PayoutStatus.pending:
        return (
          Icons.schedule,
          AppColors.surfaceContainerHighLight,
          AppColors.onSurfaceVariantLight,
        );
      case PayoutStatus.processing:
        return (
          Icons.sync,
          AppColors.secondaryContainerLight,
          AppColors.onSecondaryContainerLight,
        );
      case PayoutStatus.failed:
        return (
          Icons.error_outline,
          AppColors.errorContainerLight,
          AppColors.errorLight,
        );
    }
  }

  Color get _statusColor {
    switch (payout.status) {
      case PayoutStatus.completed:
        return AppColors.primaryLight;
      case PayoutStatus.pending:
        return AppColors.onSurfaceVariantLight;
      case PayoutStatus.processing:
        return AppColors.secondaryLight;
      case PayoutStatus.failed:
        return AppColors.errorLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, iconBg, iconFg) = _iconStyle;
    final isFailed = payout.status == PayoutStatus.failed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFailed ? AppColors.errorLight : AppColors.outlineVariantLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration:
                    BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconFg, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payout.periodLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${payout.method} • ${payout.dateLabel}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariantLight,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TK${payout.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceLight,
                    ),
                  ),
                  Text(
                    payout.status.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isFailed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.errorLight,
                  side: BorderSide(color: AppColors.errorLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'Retry Payout',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
