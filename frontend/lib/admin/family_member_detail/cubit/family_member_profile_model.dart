import 'package:equatable/equatable.dart';

/// Whether this family member's account is active or suspended.
enum AccountStatus { active, suspended }

/// An elderly user linked to this family member.
class LinkedElderlyUser extends Equatable {
  const LinkedElderlyUser({
    required this.name,
    required this.avatarUrl,
    required this.relationship,
    required this.isPrimaryContact,
  });

  final String name;
  final String avatarUrl;

  /// The elderly user's relationship to this family member, e.g.
  /// "Father", "Mother" — described from the family member's point of
  /// view (matches the original design's "Father" label).
  final String relationship;
  final bool isPrimaryContact;

  @override
  List<Object?> get props => [name, avatarUrl, relationship, isPrimaryContact];
}

/// A single notification-category row in the "Alert Preferences" card.
/// Display-only on this admin screen — not editable here.
class AlertPreference extends Equatable {
  const AlertPreference({required this.label, required this.isEnabled});

  final String label;
  final bool isEnabled;

  @override
  List<Object?> get props => [label, isEnabled];
}

/// Full profile record for a single family member, shown on the admin
/// Family Member Profile detail screen.
class FamilyMemberProfile extends Equatable {
  const FamilyMemberProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.status,
    required this.gender,
    required this.age,
    required this.phone,
    required this.email,
    required this.address,
    required this.linkedElderlyUsers,
    required this.alertPreferences,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final AccountStatus status;
  final String gender;
  final int age;
  final String phone;
  final String email;
  final String address;
  final List<LinkedElderlyUser> linkedElderlyUsers;
  final List<AlertPreference> alertPreferences;

  FamilyMemberProfile copyWith({AccountStatus? status}) {
    return FamilyMemberProfile(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      status: status ?? this.status,
      gender: gender,
      age: age,
      phone: phone,
      email: email,
      address: address,
      linkedElderlyUsers: linkedElderlyUsers,
      alertPreferences: alertPreferences,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    status,
    gender,
    age,
    phone,
    email,
    address,
    linkedElderlyUsers,
    alertPreferences,
  ];
}