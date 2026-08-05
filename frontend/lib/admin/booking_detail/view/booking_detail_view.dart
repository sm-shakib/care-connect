import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../cubit/booking_detail_cubit.dart';
import '../cubit/booking_detail_state.dart';
import 'widgets/booking_detail_actions_bar.dart';
import 'widgets/booking_summary_card.dart';
import 'widgets/care_logs_section.dart';
import 'widgets/location_card.dart';
import 'widgets/participants_section.dart';
import 'widgets/payment_status_section.dart';
import 'widgets/schedule_card.dart';

/// Presentational scaffold for the Booking Details screen. Pushed from
/// `booking_management` when an admin taps "View Details" on a card.
class BookingDetailView extends StatelessWidget {
  const BookingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(context),
      body: BlocBuilder<BookingDetailCubit, BookingDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.loadStatus == BookingDetailLoadStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Something went wrong.',
                  style: TextStyle(color: AppColors.onSurfaceVariantLight),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final booking = state.booking;
          if (booking == null) return const SizedBox.shrink();

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    _horizontalPadding(context),
                    16,
                    _horizontalPadding(context),
                    // Extra bottom room so content clears the pinned
                    // bottom action bar.
                    140,
                  ),
                  children: [
                    BookingSummaryCard(booking: booking),
                    const SizedBox(height: 20),
                    ParticipantsSection(
                      careRecipient: booking.careRecipient,
                      caregiver: booking.caregiver,
                      onCallRecipient: () {
                        // TODO(careconnect): launch a phone call
                        // (url_launcher tel: scheme) to the care
                        // recipient's number.
                      },
                      onChatCaregiver: () {
                        // TODO(careconnect): open an in-app chat
                        // thread with the caregiver.
                      },
                    ),
                    const SizedBox(height: 20),
                    ScheduleCard(
                      startDateLabel: booking.startDateLabel,
                      endDateLabel: booking.endDateLabel,
                      dailyTimingLabel: booking.dailyTimingLabel,
                    ),
                    const SizedBox(height: 20),
                    LocationCard(
                      address: booking.address,
                      onViewOnMap: () {
                        // TODO(careconnect): open a map view/deep link.
                      },
                    ),
                    const SizedBox(height: 20),
                    PaymentStatusSection(badges: booking.paymentBadges),
                    const SizedBox(height: 20),
                    CareLogsSection(logs: booking.careLogs),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomSheet: BookingDetailActionsBar(
        onSupport: () {
          // TODO(careconnect): open an admin support/escalation flow
          // for this specific booking.
        },
        onModify: () {
          // TODO(careconnect): open a booking edit flow.
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(
        bottom: BorderSide(color: AppColors.outlineVariantLight),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primaryLight),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        'Booking Details',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryLight,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications,
            color: AppColors.primaryLight,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 360 ? 16 : 20;
  }
}