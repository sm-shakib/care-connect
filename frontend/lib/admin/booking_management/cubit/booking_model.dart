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
    required this.startDate,
    required this.requestedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final elder = json['elder'] as Map<String, dynamic>?;
    final caregiver = json['caregiver'] as Map<String, dynamic>?;

    final startDate = DateTime.parse(json['service_start_date'] as String);
    final endDate = DateTime.parse(json['service_end_date'] as String);
    final requestedAt = json['requested_at'] != null
        ? DateTime.parse(json['requested_at'] as String)
        : DateTime.now();
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

    // Normalizing dates to midnight for accurate day-based comparison
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    // Determining status based on real-life date time and backend status
    final List<BookingBadgeType> badges = [];
    BookingStatus status;

    if (statusStr == 'completed') {
      status = BookingStatus.completed;
      badges.add(BookingBadgeType.confirmed);
    } else if (statusStr == 'rejected' || statusStr == 'cancelled') {
      status = BookingStatus.completed;
    } else if (today.isAfter(end)) {
      // The service period has naturally ended
      status = BookingStatus.completed;
      if (statusStr == 'accepted') badges.add(BookingBadgeType.confirmed);
    } else if (statusStr == 'accepted') {
      badges.add(BookingBadgeType.confirmed);
      if (today.isBefore(start)) {
        status = BookingStatus.upcoming;
      } else {
        status = BookingStatus.ongoing;
        badges.add(BookingBadgeType.ongoing);
      }
    } else {
      // Defaults to upcoming for 'pending' or anything else not yet started/accepted
      status = BookingStatus.upcoming;
      if (statusStr == 'pending') {
        badges.add(BookingBadgeType.pending);
      }
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
      startDate: startDate,
      requestedAt: requestedAt,
    );
  }

  final String id;
  final BookingPerson user;
  final BookingPerson caregiver;
  final double totalAmount;
  final String dateLabel;
  final BookingStatus status;
  final List<BookingBadgeType> badges;
  final DateTime startDate;
  final DateTime requestedAt;

  @override
  List<Object?> get props => [
        id,
        user,
        caregiver,
        totalAmount,
        dateLabel,
        status,
        badges,
        startDate,
        requestedAt,
      ];
}
