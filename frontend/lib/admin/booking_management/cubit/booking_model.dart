import 'package:equatable/equatable.dart';

/// The elderly user or caregiver shown on a booking card.
class BookingPerson extends Equatable {
  const BookingPerson({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  final String name;
  final String role;
  final String avatarUrl;

  @override
  List<Object?> get props => [name, role, avatarUrl];
}

/// The coarse status bucket a booking belongs to — matches the filter
/// chips (minus "All").
enum BookingStatus { upcoming, ongoing, completed }

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.upcoming:
        return 'Upcoming';
      case BookingStatus.ongoing:
        return 'Ongoing';
      case BookingStatus.completed:
        return 'Completed';
    }
  }
}

/// Every specific badge chip a booking card can show. Each carries its
/// own icon + color combo (matching the original design exactly, where
/// e.g. "Confirmed" and "Paid" have distinct colors from "Checked-in"),
/// so this is intentionally more granular than [BookingStatus].
enum BookingBadgeType {
  confirmed,
  paid,
  notStarted,
  ongoing,
  partiallyPaid,
  checkedIn,
  pending,
  unpaid,
}

/// A single booking record shown on the admin bookings list.
class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.user,
    required this.caregiver,
    required this.totalAmount,
    required this.dateLabel,
    required this.status,
    required this.badges,
  });

  final String id;
  final BookingPerson user;
  final BookingPerson caregiver;
  final double totalAmount;

  /// Pre-formatted date/time text (e.g. "Oct 25 - Oct 27, 2023" or
  /// "Nov 02, 2023 | 08:00 - 14:00") — kept as a display string since
  /// the two card formats in the original design don't share a single
  /// date-range shape.
  final String dateLabel;
  final BookingStatus status;
  final List<BookingBadgeType> badges;

  @override
  List<Object?> get props => [
    id,
    user,
    caregiver,
    totalAmount,
    dateLabel,
    status,
    badges,
  ];
}