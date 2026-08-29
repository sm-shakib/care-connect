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

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id']?.toString() ?? '',
      name: (json['name'] as String?) ?? (json['email'] as String?) ?? 'Unknown',
      avatarUrl: (json['profile_image_url'] as String?) ?? '',
      role: _parseRole(json['role'] as String?),
      phone: (json['phone'] as String?) ?? '',
      joinedDate: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      status: json['is_active'] == true ? UserStatus.active : UserStatus.suspended,
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'elder':
        return UserRole.elderly;
      case 'caregiver':
        return UserRole.caregiver;
      case 'family':
        return UserRole.family;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.elderly;
    }
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        avatarUrl,
        role,
        phone,
        joinedDate,
        status,
      ];
}
