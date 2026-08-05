import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../../booking_detail/view/booking_detail_page.dart';
import '../cubit/booking_management_cubit.dart';
import '../cubit/booking_management_state.dart';
import 'widgets/booking_card.dart';
import 'widgets/booking_filter_chips.dart';

/// Tab body for the Bookings screen, rendered inside `AdminShellView`'s
/// `IndexedStack`. No bottom nav bar of its own (the shell provides
/// one shared nav bar) and no FAB — the original design explicitly
/// suppresses the FAB here since this is a management/detail-focused
/// list, not a creation flow.
class BookingManagementView extends StatelessWidget {
  const BookingManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _horizontalPadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 12),
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
                              'No bookings in this category.',
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      shape: Border(
        bottom: BorderSide(color: AppColors.outlineVariantLight),
      ),
      titleSpacing: 20,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          //Icon(Icons.event_available, color: AppColors.primaryLight),
          //const SizedBox(width: 12),
          Text(
            'Bookings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
      actions: [
        /*IconButton(
          icon: Icon(Icons.search, color: AppColors.onSurfaceVariantLight),
          onPressed: () {},
        ),*/
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