import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver/caregiver_details/view/caregiver_details_page.dart';
import 'package:frontend/caregiver/caregiver_list/cubit/caregiver_list_cubit.dart';
import 'package:frontend/caregiver/caregiver_list/view/caregiver_list_body.dart';
import 'package:frontend/caregiver/models/booking_request.dart';
import 'package:frontend/family/cubit/family_dashboard_cubit.dart';
import 'package:frontend/family/cubit/family_dashboard_state.dart';
import 'package:frontend/theme/app_colors.dart';

class CaregiverListView extends StatelessWidget {
  const CaregiverListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Capture the family cubit here to pass it into the details route
    final familyCubit = context.read<FamilyDashboardCubit>();

    return Material(
      color: Colors.transparent,
      child: MultiBlocListener(
        listeners: [
          BlocListener<FamilyDashboardCubit, FamilyDashboardState>(
            listenWhen: (prev, curr) =>
                prev.bookingForElder != curr.bookingForElder,
            listener: (context, familyState) {
              final elder = familyState.bookingForElder;
              if (elder != null) {
                // Exclude caregivers already assigned OR pending for this elder
                final assignedIds = elder.caregiverIdMap.values.toList();
                final pendingIds = elder.bookings
                    .where((b) => b.status == BookingStatus.pending)
                    .map((b) => b.caregiverId.toString())
                    .toList();

                context
                    .read<CaregiverListCubit>()
                    .setExcludedIds([...assignedIds, ...pendingIds]);
              } else {
                context.read<CaregiverListCubit>().setExcludedIds([]);
              }
            },
          ),
        ],
        child: BlocBuilder<FamilyDashboardCubit, FamilyDashboardState>(
          builder: (context, familyState) {
            final bookingElder = familyState.bookingForElder;

            final pendingBookings = bookingElder?.bookings
                    .where((b) => b.status == BookingStatus.pending)
                    .toList() ??
                const [];

            return CaregiverListBody(
              pendingBookings: pendingBookings,
              banner: bookingElder == null
                  ? null
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      color: AppColors.paleMint,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.darkTeal,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Finding professional for: ${bookingElder.name}',
                              style: const TextStyle(
                                color: AppColors.darkTeal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.darkTeal,
                            ),
                            onPressed: familyCubit.clearBookingContext,
                          ),
                        ],
                      ),
                    ),
              onCaregiverTap: (caregiver) {
                unawaited(
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider.value(
                        value: familyCubit,
                        child: CaregiverDetailsPage(
                          caregiver: caregiver,
                          bookingForElder: bookingElder,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
