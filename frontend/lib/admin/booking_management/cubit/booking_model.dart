import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

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

/// The coarse status bucket a booking belongs to.
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

/// Every specific badge chip a booking card can show.
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

  factory Booking.fromJson(Map<String, dynamic> json) {
    final elder = json['elder'] as Map<String, dynamic>?;
    final caregiver = json['caregiver'] as Map<String, dynamic>?;
    final caregiverUser =
        caregiver != null ? caregiver['user'] as Map<String, dynamic>? : null;

    final startDate = DateTime.parse(json['service_start_date'] as String);
    final endDate = DateTime.parse(json['service_end_date'] as String);
    final statusStr = json['status'] as String? ?? 'pending';
    final paymentStatus = json['payment_status'] as String? ?? 'pending';

    // Formatting date label
    final dateFmt = DateFormat('MMM d');
    final yearFmt = DateFormat('yyyy');
    final String dateLabel;
    if (startDate.year == endDate.year) {
      dateLabel =
          '${dateFmt.format(startDate)} - ${dateFmt.format(endDate)}, ${yearFmt.format(startDate)}';
    } else {
      dateLabel =
          '${dateFmt.format(startDate)}, ${yearFmt.format(startDate)} - ${dateFmt.format(endDate)}, ${yearFmt.format(endDate)}';
    }

    // Determining status and badges
    final List<BookingBadgeType> badges = [];
    final BookingStatus status;

    if (statusStr == 'accepted') {
      status = BookingStatus.ongoing;
      badges.add(BookingBadgeType.confirmed);
    } else if (statusStr == 'completed') {
      status = BookingStatus.completed;
      badges.add(BookingBadgeType.confirmed);
    } else {
      status = BookingStatus.upcoming;
      badges.add(BookingBadgeType.pending);
    }

    if (paymentStatus == 'paid') {
      badges.add(BookingBadgeType.paid);
    } else {
      badges.add(BookingBadgeType.unpaid);
    }

    return Booking(
      id: 'BK-${json['id']}',
      user: BookingPerson(
        name: elder != null ? elder['name'] as String? ?? 'Unknown' : 'Unknown',
        role: 'Elder',
        avatarUrl: elder != null ? elder['profile_image_url'] as String? ?? '' : '',
      ),
      caregiver: BookingPerson(
        name: caregiver != null ? caregiver['name'] as String? ?? 'Unknown' : 'Unknown',
        role: 'Caregiver',
        avatarUrl: caregiver != null ? caregiver['profile_image_url'] as String? ?? '' : '',
      ),
      totalAmount: (json['total_amount'] as num? ?? 0).toDouble(),
      dateLabel: dateLabel,
      status: status,
      badges: badges,
    );
  }

  final String id;
  final BookingPerson user;
  final BookingPerson caregiver;
  final double totalAmount;
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
