import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/repositories/admin_repository.dart';

import 'booking_filter.dart';
import 'booking_management_state.dart';
import 'booking_model.dart';

/// Manages the bookings list: loading and filtering.
class BookingManagementCubit extends Cubit<BookingManagementState> {
  BookingManagementCubit({AdminRepository? adminRepository})
      : _adminRepository = adminRepository ?? AdminRepository(),
        super(const BookingManagementState());

  final AdminRepository _adminRepository;

  Future<void> loadBookings() async {
    emit(state.copyWith(status: BookingManagementStatus.loading));
    try {
      final filterStatus = _mapFilterToStatus(state.filter);
      final results = await _adminRepository.getBookings(status: filterStatus);

      final bookings = results
          .map((dynamic json) => Booking.fromJson(json as Map<String, dynamic>))
          .toList();

      emit(
        state.copyWith(
          status: BookingManagementStatus.success,
          bookings: bookings,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: BookingManagementStatus.failure,
          errorMessage: 'Unable to load bookings. Please try again.',
        ),
      );
    }
  }

  String? _mapFilterToStatus(BookingFilter filter) {
    switch (filter) {
      case BookingFilter.all:
        return null;
      case BookingFilter.upcoming:
        return 'pending';
      case BookingFilter.ongoing:
        return 'accepted';
      case BookingFilter.completed:
        return 'completed';
    }
  }

  void filterChanged(BookingFilter filter) {
    emit(state.copyWith(filter: filter));
    // Trigger reload when filter changes
    // ignore: discarded_futures
    loadBookings();
  }

  void searchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
