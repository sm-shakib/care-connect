import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_profile_model.dart';

/// "Recent Bookings" section with a "View All" header action.
class CaregiverRecentBookingsSection extends StatelessWidget {
  const CaregiverRecentBookingsSection({
    required this.bookings,
    this.onViewAll,
    this.onBookingTap,
    super.key,
  });

  final List<CaregiverBookingSummary> bookings;
  final VoidCallback? onViewAll;
  final ValueChanged<CaregiverBookingSummary>? onBookingTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Bookings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceLight,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
        if (bookings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariantLight),
            ),
            child: const Text(
              'No bookings yet.',
              style: TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariantLight),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < bookings.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, color: AppColors.outlineVariantLight),
                  _BookingRow(
                    booking: bookings[i],
                    onTap: () => onBookingTap?.call(bookings[i]),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.booking, this.onTap});

  final CaregiverBookingSummary booking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainerLight,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.person, color: AppColors.onSecondaryContainerLight),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.elderlyUserName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    booking.dateRangeLabel,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariantLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighestLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                booking.statusLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariantLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
