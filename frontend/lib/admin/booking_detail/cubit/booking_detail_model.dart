import 'package:equatable/equatable.dart';

/// A person involved in the booking (care recipient or caregiver).
class BookingParticipant extends Equatable {
  const BookingParticipant({
    required this.role,
    required this.name,
    required this.avatarUrl,
  });

  /// e.g. "Care Recipient", "Primary Caregiver".
  final String role;
  final String name;
  final String avatarUrl;

  @override
  List<Object?> get props => [role, name, avatarUrl];
}

/// The coarse status bucket a booking belongs to. Duplicated from
/// `booking_management` (rather than imported) so this feature stays
/// self-contained — same approach used for status enums across other
/// detail/list feature pairs in this app.
enum BookingDetailStatus { upcoming, ongoing, completed, cancelled }

extension BookingDetailStatusX on BookingDetailStatus {
  String get label {
    switch (this) {
      case BookingDetailStatus.upcoming:
        return 'Upcoming';
      case BookingDetailStatus.ongoing:
        return 'Ongoing';
      case BookingDetailStatus.completed:
        return 'Completed';
      case BookingDetailStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Every specific payment/progress badge a booking can show — mirrors
/// `booking_management`'s `BookingBadgeType` so the same booking looks
/// consistent between the list and this detail page.
enum PaymentBadgeType {
  confirmed,
  paid,
  notStarted,
  ongoing,
  partiallyPaid,
  checkedIn,
  pending,
  unpaid,
}

/// A single check-in/check-out (or similar) care log entry. Fills the
/// original design's empty "Care Logs Timeline" placeholder — backed
/// by the `checkin`/`checkout` booking endpoints already in the ER
/// diagram, so this isn't inventing new data, just surfacing it.
class CareLogEntry extends Equatable {
  const CareLogEntry({
    required this.label,
    required this.timeLabel,
    required this.iconName,
  });

  /// e.g. "Checked In", "Checked Out".
  final String label;
  final String timeLabel;
  final String iconName;

  @override
  List<Object?> get props => [label, timeLabel, iconName];
}

/// Full detail record for a single booking, shown on the admin
/// Booking Details screen.
class BookingDetail extends Equatable {
  const BookingDetail({
    required this.id,
    required this.category,
    required this.status,
    required this.totalAmount,
    required this.careRecipient,
    required this.caregiver,
    required this.startDateLabel,
    required this.endDateLabel,
    required this.dailyTimingLabel,
    required this.address,
    required this.paymentBadges,
    required this.careLogs,
  });

  final String id;
  final String category;
  final BookingDetailStatus status;
  final double totalAmount;
  final BookingParticipant careRecipient;
  final BookingParticipant caregiver;
  final String startDateLabel;
  final String endDateLabel;
  final String dailyTimingLabel;
  final String address;
  final List<PaymentBadgeType> paymentBadges;
  final List<CareLogEntry> careLogs;

  @override
  List<Object?> get props => [
    id,
    category,
    status,
    totalAmount,
    careRecipient,
    caregiver,
    startDateLabel,
    endDateLabel,
    dailyTimingLabel,
    address,
    paymentBadges,
    careLogs,
  ];
}