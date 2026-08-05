import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/booking_detail_model.dart';

/// "Payment Status" section — the original HTML left this as an empty
/// `<!-- Payment Status -->` comment. Filled in here with the same
/// badge chips already shown on the booking card in
/// `booking_management` (Confirmed/Paid/Not Started, etc.), so an
/// admin can see payment progress without navigating back.
class PaymentStatusSection extends StatelessWidget {
  const PaymentStatusSection({required this.badges, super.key});

  final List<PaymentBadgeType> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Payment Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceLight,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowestLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariantLight),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final badge in badges) _BadgeChip(type: badge),
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.type});

  final PaymentBadgeType type;

  (IconData, String, Color, Color) get _style {
    switch (type) {
      case PaymentBadgeType.confirmed:
        return (
        Icons.check_circle,
        'Confirmed',
        AppColors.primaryContainerLight,
        AppColors.onPrimaryContainerLight,
        );
      case PaymentBadgeType.paid:
        return (
        Icons.payments,
        'Paid',
        AppColors.tertiaryContainerLight,
        AppColors.onTertiaryContainerLight,
        );
      case PaymentBadgeType.notStarted:
        return (
        Icons.timer,
        'Not Started',
        AppColors.surfaceVariantLight,
        AppColors.onSurfaceVariantLight,
        );
      case PaymentBadgeType.ongoing:
        return (
        Icons.sync,
        'Ongoing',
        AppColors.secondaryContainerLight,
        AppColors.onSecondaryContainerLight,
        );
      case PaymentBadgeType.partiallyPaid:
        return (
        Icons.pending,
        'Partially Paid',
        AppColors.errorContainerLight,
        AppColors.onErrorContainerLight,
        );
      case PaymentBadgeType.checkedIn:
        return (
        Icons.location_on,
        'Checked-in',
        AppColors.onPrimaryFixedVariantLight,
        AppColors.primaryFixedLight,
        );
      case PaymentBadgeType.pending:
        return (
        Icons.history,
        'Pending',
        AppColors.surfaceVariantLight,
        AppColors.onSurfaceVariantLight,
        );
      case PaymentBadgeType.unpaid:
        return (
        Icons.info,
        'Unpaid',
        AppColors.errorContainerLight,
        AppColors.onErrorContainerLight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, label, bg, fg) = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}