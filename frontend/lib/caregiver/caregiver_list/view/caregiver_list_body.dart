import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver/caregiver_list/cubit/caregiver_list_cubit.dart';
import 'package:frontend/caregiver/caregiver_list/cubit/caregiver_list_state.dart';
import 'package:frontend/caregiver/models/booking_request.dart';
import 'package:frontend/caregiver/models/caregiver.dart';
import 'package:frontend/caregiver/widgets/caregiver_card.dart';
import 'package:frontend/caregiver/widgets/caregiver_filter_chip.dart';
import 'package:frontend/caregiver/widgets/caregiver_search_bar.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/theme/app_colors.dart';

/// Reusable caregiver browsing UI: search bar, specialty filter chips, and
/// the resulting caregiver list.
///
/// Must be placed under a [CaregiverListCubit] (via [BlocProvider]). An
/// optional [banner] can be rendered above the search bar (e.g. to surface
/// booking context), while [onCaregiverTap] controls what happens when a
/// caregiver card is tapped, letting callers reuse this body across
/// different roles/flows (family booking, elder browsing, etc.).
class CaregiverListBody extends StatelessWidget {
  const CaregiverListBody({
    required this.onCaregiverTap,
    this.banner,
    this.pendingBookings = const [],
    super.key,
  });

  final ValueChanged<Caregiver> onCaregiverTap;
  final Widget? banner;
  final List<BookingRequest> pendingBookings;

  void _showPendingRequestsPopup(
    BuildContext context,
    List<BookingRequest> bookings,
  ) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.outbound_outlined,
                    color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Sent Requests',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${bookings.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "You've sent booking requests to these caregivers. "
              "They'll appear in your care team once they accept.",
              style: TextStyle(
                color: AppColors.onSurfaceVariantLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bookings.length,
                itemBuilder: (context, index) =>
                    _PendingCaregiverAvatar(booking: bookings[index]),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CaregiverListCubit, CaregiverListState>(
      builder: (context, state) {
        return Column(
          children: [
            banner ?? const SizedBox.shrink(),

            /// Pending Requests Summary Button
            if (pendingBookings.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: InkWell(
                  onTap: () =>
                      _showPendingRequestsPopup(context, pendingBookings),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.outbound_outlined,
                            color: Colors.orange, size: 20),
                        const SizedBox(width: 10),
                        const Text(
                          'Sent Requests',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${pendingBookings.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            /// Search Bar
            CaregiverSearchBar(
              onChanged: (value) {
                context.read<CaregiverListCubit>().searchCaregiver(value);
              },
            ),

            /// Filter Chips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  CaregiverFilterChip(
                    label: context.l10n.filterAll,
                    selected: state.selectedFilter == 'All',
                    onTap: () {
                      context
                          .read<CaregiverListCubit>()
                          .filterCaregivers('All');
                    },
                  ),
                  CaregiverFilterChip(
                    label: context.l10n.filterPhysiotherapy,
                    selected: state.selectedFilter == 'Physiotherapy',
                    onTap: () {
                      context
                          .read<CaregiverListCubit>()
                          .filterCaregivers('Physiotherapy');
                    },
                  ),
                  CaregiverFilterChip(
                    label: context.l10n.filterSeniorCare,
                    selected: state.selectedFilter == 'Senior Care',
                    onTap: () {
                      context
                          .read<CaregiverListCubit>()
                          .filterCaregivers('Senior Care');
                    },
                  ),
                  CaregiverFilterChip(
                    label: context.l10n.filterHomeNursing,
                    selected: state.selectedFilter == 'Home Nursing',
                    onTap: () {
                      context
                          .read<CaregiverListCubit>()
                          .filterCaregivers('Home Nursing');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// Caregiver List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: state.filteredCaregivers.length,
                itemBuilder: (context, index) {
                  final caregiver = state.filteredCaregivers[index];
                  return CaregiverCard(
                    caregiver: caregiver,
                    onTap: () => onCaregiverTap(caregiver),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PendingCaregiverAvatar extends StatelessWidget {
  const _PendingCaregiverAvatar({required this.booking});

  final BookingRequest booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                backgroundImage: booking.caregiverEntity?.imageUrl.isNotEmpty == true
                    ? NetworkImage(booking.caregiverEntity!.imageUrl)
                    : null,
                child: booking.caregiverEntity?.imageUrl.isEmpty == true
                    ? const Icon(Icons.person, color: Colors.orange, size: 30)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_empty,
                    size: 12,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.caregiverName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            'Pending',
            style: TextStyle(
              fontSize: 10,
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
