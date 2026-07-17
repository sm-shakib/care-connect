import 'package:equatable/equatable.dart';

/// The role a user account is registered under.
enum UserRole { elderly, family, caregiver, admin }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.elderly:
        return 'Elderly';
      case UserRole.family:
        return 'Family';
      case UserRole.caregiver:
        return 'Caregiver';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

/// Whether an account is currently active or has been suspended.
enum UserStatus { active, suspended }

/// A single row in the User Management list.
class UserAccount extends Equatable {
  const UserAccount({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.role,
    required this.phone,
    required this.joinedDate,
    required this.status,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final UserRole role;
  final String phone;
  final DateTime joinedDate;
  final UserStatus status;

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    role,
    phone,
    joinedDate,
    status,
  ];
}