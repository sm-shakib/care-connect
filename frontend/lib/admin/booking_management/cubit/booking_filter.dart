import 'booking_model.dart';

/// Filter chip options shown at the top of the bookings list.
enum BookingFilter { all, upcoming, ongoing, completed }

extension BookingFilterX on BookingFilter {
  String get label {
    switch (this) {
      case BookingFilter.all:
        return 'All';
      case BookingFilter.upcoming:
        return 'Upcoming';
      case BookingFilter.ongoing:
        return 'Ongoing';
      case BookingFilter.completed:
        return 'Completed';
    }
  }

  /// Whether a booking with [status] should be shown under this filter.
  bool matches(BookingStatus status) {
    switch (this) {
      case BookingFilter.all:
        return true;
      case BookingFilter.upcoming:
        return status == BookingStatus.upcoming;
      case BookingFilter.ongoing:
        return status == BookingStatus.ongoing;
      case BookingFilter.completed:
        return status == BookingStatus.completed;
    }
  }
}