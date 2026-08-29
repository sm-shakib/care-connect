import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// A person involved in the booking (care recipient or caregiver).
class BookingParticipant extends Equatable {
  const BookingParticipant({
    required this.id,
    required this.role,
    required this.name,
    required this.avatarUrl,
    required this.phoneNumber,
  });

  final String id;
  final String role;
  final String name;
  final String avatarUrl;
  final String phoneNumber;

  @override
  List<Object?> get props => [id, role, name, avatarUrl, phoneNumber];
}

/// The coarse status bucket a booking belongs to.
enum BookingDetailStatus { upcoming, ongoing, completed }

extension BookingDetailStatusX on BookingDetailStatus {
  String get label {
    switch (this) {
      case BookingDetailStatus.upcoming:
        return 'Upcoming';
      case BookingDetailStatus.ongoing:
        return 'Ongoing';
      case BookingDetailStatus.completed:
        return 'Completed';
    }
  }
}

/// Every specific payment/progress badge a booking can show.
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

/// A single check-in/check-out (or similar) care log entry.
class CareLogEntry extends Equatable {
  const CareLogEntry({
    required this.label,
    required this.timeLabel,
    required this.iconName,
  });

  final String label;
  final String timeLabel;
  final String iconName;

  @override
  List<Object?> get props => [label, timeLabel, iconName];
}

/// Full detail record for a single booking.
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

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    final elder = json['elder'] as Map<String, dynamic>?;
    final caregiver = json['caregiver'] as Map<String, dynamic>?;

    final startDate = DateTime.parse(json['service_start_date'] as String);
    final endDate = DateTime.parse(json['service_end_date'] as String);
    final statusStr = json['status'] as String? ?? 'pending';
    final paymentStatus = json['payment_status'] as String? ?? 'pending';

    final dateFmt = DateFormat('MMMM d, yyyy');

    final List<PaymentBadgeType> badges = [];
    final BookingDetailStatus status;

    if (statusStr == 'accepted') {
      status = BookingDetailStatus.ongoing;
      badges.add(PaymentBadgeType.confirmed);
    } else if (statusStr == 'completed') {
      status = BookingDetailStatus.completed;
      badges.add(PaymentBadgeType.confirmed);
    } else {
      status = BookingDetailStatus.upcoming;
      badges.add(PaymentBadgeType.pending);
    }

    if (paymentStatus == 'paid') {
      badges.add(PaymentBadgeType.paid);
    } else {
      badges.add(PaymentBadgeType.unpaid);
    }

    return BookingDetail(
      id: 'BK-${json['id']}',
      category: json['booking_reason'] as String? ?? 'Companion Care',
      status: status,
      totalAmount: (json['total_amount'] as num? ?? 0).toDouble(),
      careRecipient: BookingParticipant(
        id: elder != null ? elder['user_id'].toString() : '',
        role: 'Care Recipient',
        name: elder != null ? elder['name'] as String? ?? '' : '',
        avatarUrl: elder != null ? elder['profile_image_url'] as String? ?? '' : '',
        phoneNumber: elder != null ? elder['phone'] as String? ?? '' : '',
      ),
      caregiver: BookingParticipant(
        id: caregiver != null ? caregiver['user_id'].toString() : '',
        role: 'Primary Caregiver',
        name: caregiver != null ? caregiver['name'] as String? ?? '' : '',
        avatarUrl: caregiver != null ? caregiver['profile_image_url'] as String? ?? '' : '',
        phoneNumber: caregiver != null ? caregiver['phone'] as String? ?? '' : '',
      ),
      startDateLabel: dateFmt.format(startDate),
      endDateLabel: dateFmt.format(endDate),
      dailyTimingLabel:
          '${json['daily_timing_start']} - ${json['daily_timing_end']}',
      address: elder != null ? elder['address'] as String? ?? '' : '',
      paymentBadges: badges,
      careLogs: const [], // Backend doesn't support care logs yet
    );
  }

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
