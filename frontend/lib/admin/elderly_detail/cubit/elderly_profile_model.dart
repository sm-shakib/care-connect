import 'package:equatable/equatable.dart';

/// Whether this elderly user's account is active or suspended by admin.
enum AccountStatus { active, suspended }

/// A family member linked to this elderly user.
class LinkedFamilyMember extends Equatable {
  const LinkedFamilyMember({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.relationship,
    required this.isPrimaryContact,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final String relationship;
  final bool isPrimaryContact;

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        avatarUrl,
        relationship,
        isPrimaryContact,
      ];
}

/// Outcome of a past SOS event, shown in the "Recent SOS Events" list.
enum SosEventStatus { resolved, falseAlarm, pending }

extension SosEventStatusX on SosEventStatus {
  String get label {
    switch (this) {
      case SosEventStatus.resolved:
        return 'Resolved';
      case SosEventStatus.falseAlarm:
        return 'False Alarm';
      case SosEventStatus.pending:
        return 'Pending';
    }
  }
}

/// A single past SOS event summary.
class SosEventSummary extends Equatable {
  const SosEventSummary({
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
  });

  final String dateLabel;
  final String timeLabel;
  final SosEventStatus status;

  @override
  List<Object?> get props => <Object?>[dateLabel, timeLabel, status];
}

/// Full profile record for a single elderly user.
class ElderlyProfile extends Equatable {
  const ElderlyProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.status,
    required this.gender,
    required this.age,
    required this.phone,
    required this.email,
    required this.address,
    required this.healthCondition,
    required this.linkedFamilyMembers,
    required this.recentSosEvents,
  });

  factory ElderlyProfile.fromJson(
    Map<String, dynamic> json, {
    AccountStatus? accountStatus,
  }) {
    final dobStr = json['date_of_birth'] as String?;
    var ageValue = 0;
    if (dobStr != null) {
      final dob = DateTime.parse(dobStr);
      ageValue = DateTime.now().year - dob.year;
    }

    return ElderlyProfile(
      id: json['id']?.toString() ?? '',
      name: (json['name'] as String?) ?? (json['email'] as String?) ?? '',
      avatarUrl: (json['profile_image_url'] as String?) ?? '',
      status: accountStatus ?? AccountStatus.active,
      gender: (json['gender'] as String?) ?? '',
      age: ageValue,
      phone: (json['phone'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      healthCondition: (json['health_condition'] as String?) ?? '',
      linkedFamilyMembers: const [],
      recentSosEvents: const [],
    );
  }

  final String id;
  final String name;
  final String avatarUrl;
  final AccountStatus status;
  final String gender;
  final int age;
  final String phone;
  final String email;
  final String address;
  final String healthCondition;
  final List<LinkedFamilyMember> linkedFamilyMembers;
  final List<SosEventSummary> recentSosEvents;

  ElderlyProfile copyWith({AccountStatus? status}) {
    return ElderlyProfile(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      status: status ?? this.status,
      gender: gender,
      age: age,
      phone: phone,
      email: email,
      address: address,
      healthCondition: healthCondition,
      linkedFamilyMembers: linkedFamilyMembers,
      recentSosEvents: recentSosEvents,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        avatarUrl,
        status,
        gender,
        age,
        phone,
        email,
        address,
        healthCondition,
        linkedFamilyMembers,
        recentSosEvents,
      ];
}
