import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../../booking_detail/view/booking_detail_page.dart';
import '../cubit/booking_management_cubit.dart';
import '../cubit/booking_management_state.dart';
import 'widgets/booking_card.dart';
import 'widgets/booking_filter_chips.dart';
import 'widgets/booking_search_bar.dart';

/// Content body for the Bookings management screen.
class BookingManagementView extends StatelessWidget {
  const BookingManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _horizontalPadding(context),
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BookingSearchBar(
                  onChanged: context
                      .read<BookingManagementCubit>()
                      .searchChanged,
                ),
                const SizedBox(height: 16),
                BlocBuilder<BookingManagementCubit, BookingManagementState>(
                  buildWhen: (previous, current) =>
                  previous.filter != current.filter,
                  builder: (context, state) {
                    return BookingFilterChips(
                      selected: state.filter,
                      onSelected: context
                          .read<BookingManagementCubit>()
                          .filterChanged,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<BookingManagementCubit,
                      BookingManagementState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state.status ==
                          BookingManagementStatus.failure) {
                        return Center(
                          child: Text(
                            state.errorMessage ?? 'Something went wrong.',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariantLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final bookings = state.filteredBookings;

                      if (bookings.isEmpty) {
                        return Center(
                          child: Text(
                            'No bookings match your search.',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariantLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: context
                            .read<BookingManagementCubit>()
                            .loadBookings,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: bookings.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            return BookingCard(
                              booking: booking,
                              onViewDetails: () {
                                Navigator.of(context).push(
                                  BookingDetailPage.route(
                                    bookingId: booking.id,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 360 ? 16 : 20;
  }
}
