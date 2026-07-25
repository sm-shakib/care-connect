import 'package:equatable/equatable.dart';

import 'booking_filter.dart';
import 'booking_model.dart';

enum BookingManagementStatus { initial, loading, success, failure }

class BookingManagementState extends Equatable {
  const BookingManagementState({
    this.status = BookingManagementStatus.initial,
    this.bookings = const <Booking>[],
    this.filter = BookingFilter.all,
    this.errorMessage,
  });

  final BookingManagementStatus status;
  final List<Booking> bookings;
  final BookingFilter filter;
  final String? errorMessage;

  List<Booking> get filteredBookings =>
      bookings.where((booking) => filter.matches(booking.status)).toList();

  bool get isLoading => status == BookingManagementStatus.loading;

  bool get isEmpty =>
      status == BookingManagementStatus.success && filteredBookings.isEmpty;

  BookingManagementState copyWith({
    BookingManagementStatus? status,
    List<Booking>? bookings,
    BookingFilter? filter,
    String? errorMessage,
  }) {
    return BookingManagementState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      filter: filter ?? this.filter,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bookings, filter, errorMessage];
}