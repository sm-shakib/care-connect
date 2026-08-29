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

/// A single payout record.
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
  final String periodLabel;
  final double amount;
  final String method;
  final PayoutStatus status;
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

/// Full profile record for a single caregiver.
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

  factory CaregiverProfile.fromJson(
    Map<String, dynamic> json, {
    AccountStatus? accountStatus,
  }) {
    final docs = (json['documents'] as List? ?? []).map((dynamic d) {
      final map = d as Map<String, dynamic>;
      return CaregiverDocument(
        title: map['document_type'] as String? ?? '',
        subtitle: map['is_verified'] == true ? 'Verified' : 'Pending Review',
        previewUrl: map['document_url'] as String? ?? '',
        iconName: 'description',
      );
    }).toList();

    final specs = (json['specializations'] as String? ?? '')
        .split(',')
        .where((String s) => s.isNotEmpty)
        .map((String s) => SpecializationTag(label: s.trim()))
        .toList();

    return CaregiverProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['profile_image_url'] as String? ?? '',
      status: accountStatus ?? AccountStatus.active,
      title: 'Professional Caregiver',
      isVerified: json['status'] == 'verified',
      rating: (json['rating'] as num? ?? 0).toDouble(),
      reviewCount: json['review_count'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      experienceYears: json['experience_years'] as int? ?? 0,
      availability: json['availability_type'] as String? ?? '',
      hourlyRate: (json['hourly_rate'] as num? ?? 0).toDouble(),
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      specializations: specs,
      verificationChecklist: docs
          .map(
            (CaregiverDocument d) => VerificationChecklistItem(
              label: d.title,
              isVerified: d.subtitle == 'Verified',
            ),
          )
          .toList(),
      documents: docs,
      recentBookings: const [],
      totalEarned: 0,
      pendingAmount: 0,
      thisMonthAmount: 0,
      nextPayoutDateLabel: null,
      recentPayouts: const [],
    );
  }

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
