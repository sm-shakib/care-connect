import 'package:equatable/equatable.dart';

/// A specialization chip. [isPrimary] marks the highlighted/filled chip.
class SpecializationTag extends Equatable {
  const SpecializationTag({required this.label, this.isPrimary = false});

  final String label;
  final bool isPrimary;

  @override
  List<Object?> get props => [label, isPrimary];
}

/// A single row in the "Verification Status" checklist.
///
/// NOTE: labels here (ID Proof, Nursing License, Background Check) are
/// placeholders. Replace with the real values from your project's
/// `CaregiverDocumentType` enum once you share it — this checklist and
/// `caregiver_review`'s equivalent should reference the same document
/// types instead of two independently-guessed lists.
class VerificationChecklistItem extends Equatable {
  const VerificationChecklistItem({
    required this.label,
    required this.isVerified,
  });

  final String label;
  final bool isVerified;

  @override
  List<Object?> get props => [label, isVerified];
}

/// A single uploaded verification document.
class CaregiverDocument extends Equatable {
  const CaregiverDocument({
    required this.title,
    required this.subtitle,
    required this.previewUrl,
    required this.iconName,
  });

  final String title;
  final String subtitle;
  final String previewUrl;
  final String iconName;

  @override
  List<Object?> get props => [title, subtitle, previewUrl, iconName];
}

/// A single recent booking summary row.
class CaregiverBookingSummary extends Equatable {
  const CaregiverBookingSummary({
    required this.id,
    required this.elderlyUserName,
    required this.dateRangeLabel,
    required this.statusLabel,
  });

  final String id;
  final String elderlyUserName;
  final String dateRangeLabel;
  final String statusLabel;

  @override
  List<Object?> get props => [id, elderlyUserName, dateRangeLabel, statusLabel];
}

/// Status of a single payout to this caregiver.
enum PayoutStatus { pending, processing, completed, failed }

extension PayoutStatusX on PayoutStatus {
  String get label {
    switch (this) {
      case PayoutStatus.pending:
        return 'Pending';
      case PayoutStatus.processing:
        return 'Processing';
      case PayoutStatus.completed:
        return 'Completed';
      case PayoutStatus.failed:
        return 'Failed';
    }
  }
}

/// A single payout record — backs the Earnings section. Corresponds to
/// a `Payouts` table (caregiver_id, amount, period_start/end, method,
/// status, scheduled_date, completed_at) that isn't in the original ER
/// diagram yet; without it, "Total Earned"/"Pending"/"Next Payout"
/// have nothing real to compute from.
class Payout extends Equatable {
  const Payout({
    required this.id,
    required this.periodLabel,
    required this.amount,
    required this.method,
    required this.status,
    required this.dateLabel,
  });

  final String id;

  /// e.g. "Oct 1 - Oct 15".
  final String periodLabel;
  final double amount;

  /// e.g. "Bkash", "Bank Transfer".
  final String method;
  final PayoutStatus status;

  /// Scheduled date if pending, completed date if completed — kept as
  /// a single pre-formatted label since which one applies depends on
  /// status.
  final String dateLabel;

  Payout copyWith({PayoutStatus? status}) {
    return Payout(
      id: id,
      periodLabel: periodLabel,
      amount: amount,
      method: method,
      status: status ?? this.status,
      dateLabel: dateLabel,
    );
  }

  @override
  List<Object?> get props =>
      [id, periodLabel, amount, method, status, dateLabel];
}

/// Whether this caregiver's account is active or suspended.
enum AccountStatus { active, suspended }

/// Full profile record for a single caregiver, shown on the admin
/// Caregiver Profile detail screen.
class CaregiverProfile extends Equatable {
  const CaregiverProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.status,
    required this.title,
    required this.isVerified,
    required this.rating,
    required this.reviewCount,
    required this.gender,
    required this.experienceYears,
    required this.availability,
    required this.hourlyRate,
    required this.phone,
    required this.email,
    required this.address,
    required this.specializations,
    required this.verificationChecklist,
    required this.documents,
    required this.recentBookings,
    required this.totalEarned,
    required this.pendingAmount,
    required this.thisMonthAmount,
    required this.nextPayoutDateLabel,
    required this.recentPayouts,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final AccountStatus status;
  final String title;
  final bool isVerified;
  final double rating;
  final int reviewCount;
  final String gender;
  final int experienceYears;
  final String availability;
  final double hourlyRate;
  final String phone;
  final String email;
  final String address;
  final List<SpecializationTag> specializations;
  final List<VerificationChecklistItem> verificationChecklist;
  final List<CaregiverDocument> documents;
  final List<CaregiverBookingSummary> recentBookings;

  // Earnings — computed (in a real backend) from a Payouts table.
  final double totalEarned;
  final double pendingAmount;
  final double thisMonthAmount;
  final String? nextPayoutDateLabel;
  final List<Payout> recentPayouts;

  CaregiverProfile copyWith({
    AccountStatus? status,
    List<Payout>? recentPayouts,
  }) {
    return CaregiverProfile(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      status: status ?? this.status,
      title: title,
      isVerified: isVerified,
      rating: rating,
      reviewCount: reviewCount,
      gender: gender,
      experienceYears: experienceYears,
      availability: availability,
      hourlyRate: hourlyRate,
      phone: phone,
      email: email,
      address: address,
      specializations: specializations,
      verificationChecklist: verificationChecklist,
      documents: documents,
      recentBookings: recentBookings,
      totalEarned: totalEarned,
      pendingAmount: pendingAmount,
      thisMonthAmount: thisMonthAmount,
      nextPayoutDateLabel: nextPayoutDateLabel,
      recentPayouts: recentPayouts ?? this.recentPayouts,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    status,
    title,
    isVerified,
    rating,
    reviewCount,
    gender,
    experienceYears,
    availability,
    hourlyRate,
    phone,
    email,
    address,
    specializations,
    verificationChecklist,
    documents,
    recentBookings,
    totalEarned,
    pendingAmount,
    thisMonthAmount,
    nextPayoutDateLabel,
    recentPayouts,
  ];
}