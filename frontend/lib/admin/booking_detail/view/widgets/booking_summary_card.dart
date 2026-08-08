import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/booking_detail_model.dart';

/// Top card: booking ID + category, a status pill, and total amount.
class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({required this.booking, super.key});

  final BookingDetail booking;

  (Color, Color) get _statusColors {
    switch (booking.status) {
      case BookingDetailStatus.upcoming:
        return (
          AppColors.surfaceContainerHighLight,
          AppColors.onSurfaceVariantLight,
        );
      case BookingDetailStatus.ongoing:
        return (
          AppColors.tertiaryContainerLight,
          AppColors.onTertiaryContainerLight,
        );
      case BookingDetailStatus.completed:
        return (
          AppColors.primaryContainerLight,
          AppColors.onPrimaryContainerLight,
        );
    }
  }

  IconData get _statusIcon {
    switch (booking.status) {
      case BookingDetailStatus.upcoming:
        return Icons.schedule;
      case BookingDetailStatus.ongoing:
        return Icons.check_circle;
      case BookingDetailStatus.completed:
        return Icons.task_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusBg, statusFg) = _statusColors;

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
                    Text(
                      '#${booking.id}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceLight,
                      ),
                    ),
                    Text(
                      booking.category,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onSurfaceVariantLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon, size: 16, color: statusFg),
                    const SizedBox(width: 4),
                    Text(
                      booking.status.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: statusFg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.outlineVariantLight),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariantLight,
                  ),
                ),
                Text(
                  '৳${booking.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
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