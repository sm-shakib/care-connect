import 'package:flutter_bloc/flutter_bloc.dart';

import 'booking_filter.dart';
import 'booking_management_state.dart';
import 'booking_model.dart';

/// Manages the bookings list: loading and filtering.
///
/// NOTE: [loadBookings] currently returns mock data. Swap the body of
/// that method for a call into your FastAPI bookings
/// repository/endpoint when ready.
class BookingManagementCubit extends Cubit<BookingManagementState> {
  BookingManagementCubit() : super(const BookingManagementState());

  Future<void> loadBookings() async {
    emit(state.copyWith(status: BookingManagementStatus.loading));
    try {
      // TODO(careconnect): replace with repository call to FastAPI backend.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(
        state.copyWith(
          status: BookingManagementStatus.success,
          bookings: _mockBookings,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: BookingManagementStatus.failure,
          errorMessage: 'Unable to load bookings. Please try again.',
        ),
      );
    }
  }

  void filterChanged(BookingFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  static const List<Booking> _mockBookings = [
    Booking(
      id: 'BK-3081',
      user: BookingPerson(
        name: 'Rahima Khatun',
        role: 'User',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      caregiver: BookingPerson(
        name: 'Shakib Khan',
        role: 'Caregiver',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      totalAmount: 2400,
      dateLabel: 'Oct 25 - Oct 27, 2023',
      status: BookingStatus.upcoming,
      badges: [
        BookingBadgeType.confirmed,
        BookingBadgeType.paid,
        BookingBadgeType.notStarted,
      ],
    ),
    Booking(
      id: 'BK-3082',
      user: BookingPerson(
        name: 'Abdul Jabbar',
        role: 'User',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      caregiver: BookingPerson(
        name: 'Salma Aktar',
        role: 'Caregiver',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      totalAmount: 1800,
      dateLabel: 'Nov 02, 2023 | 08:00 - 14:00',
      status: BookingStatus.ongoing,
      badges: [
        BookingBadgeType.ongoing,
        BookingBadgeType.partiallyPaid,
        BookingBadgeType.checkedIn,
      ],
    ),
    Booking(
      id: 'BK-3083',
      user: BookingPerson(
        name: 'Rahela Begum',
        role: 'User',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      caregiver: BookingPerson(
        name: 'Delwar Hossain',
        role: 'Caregiver',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      totalAmount: 3200,
      dateLabel: 'Nov 05 - Nov 10, 2023',
      status: BookingStatus.upcoming,
      badges: [BookingBadgeType.pending, BookingBadgeType.unpaid],
    ),
  ];
}