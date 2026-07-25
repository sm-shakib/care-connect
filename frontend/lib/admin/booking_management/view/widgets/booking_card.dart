import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/booking_model.dart';

/// Card for a single booking. Only shows "View Details" — the original
/// design's "Contact Support" button was dropped here since that's a
/// user-facing action, not something admins need.
class BookingCard extends StatelessWidget {
  const BookingCard({
    required this.booking,
    this.onViewDetails,
    super.key,
  });

  final Booking booking;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
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
                    _PersonRow(person: booking.user),
                    const SizedBox(height: 12),
                    _PersonRow(person: booking.caregiver),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${booking.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariantLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.outlineVariantLight),
                bottom: BorderSide(color: AppColors.outlineVariantLight),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 20, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.dateLabel,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.onSurfaceLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final badge in booking.badges) _BadgeChip(type: badge),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.onPrimaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.person});

  final BookingPerson person;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 40,
            height: 40,
            child: Image.network(
              person.avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.surfaceContainerHighLight,
                child: Icon(Icons.person, color: AppColors.outlineLight),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                person.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                person.role,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariantLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.type});

  final BookingBadgeType type;

  (IconData, String, Color, Color) get _style {
    switch (type) {
      case BookingBadgeType.confirmed:
        return (
        Icons.check_circle,
        'Confirmed',
        AppColors.primaryContainerLight,
        AppColors.onPrimaryContainerLight,
        );
      case BookingBadgeType.paid:
        return (
        Icons.payments,
        'Paid',
        AppColors.tertiaryContainerLight,
        AppColors.onTertiaryContainerLight,
        );
      case BookingBadgeType.notStarted:
        return (
        Icons.timer,
        'Not Started',
        AppColors.surfaceVariantLight,
        AppColors.onSurfaceVariantLight,
        );
      case BookingBadgeType.ongoing:
        return (
        Icons.sync,
        'Ongoing',
        AppColors.secondaryContainerLight,
        AppColors.onSecondaryContainerLight,
        );
      case BookingBadgeType.partiallyPaid:
        return (
        Icons.pending,
        'Partially Paid',
        AppColors.errorContainerLight,
        AppColors.onErrorContainerLight,
        );
      case BookingBadgeType.checkedIn:
        return (
        Icons.location_on,
        'Checked-in',
        AppColors.onPrimaryFixedVariantLight,
        AppColors.primaryFixedLight,
        );
      case BookingBadgeType.pending:
        return (
        Icons.history,
        'Pending',
        AppColors.surfaceVariantLight,
        AppColors.onSurfaceVariantLight,
        );
      case BookingBadgeType.unpaid:
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