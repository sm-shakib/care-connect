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

  UserAccount copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    UserRole? role,
    String? phone,
    DateTime? joinedDate,
    UserStatus? status,
  }) {
    return UserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      joinedDate: joinedDate ?? this.joinedDate,
      status: status ?? this.status,
    );
  }

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    DateTime joinedDate;
    final createdAt = json['created_at'];
    if (createdAt is String) {
      joinedDate = DateTime.tryParse(createdAt) ?? DateTime.now();
    } else if (createdAt is DateTime) {
      joinedDate = createdAt;
    } else {
      joinedDate = DateTime.now();
    }

    return UserAccount(
      id: json['id']?.toString() ?? '',
      name: (json['name'] as String?) ?? (json['email'] as String?) ?? 'Unknown',
      avatarUrl: (json['profile_image_url'] as String?) ?? '',
      role: _parseRole(json['role'] as String?),
      phone: (json['phone'] as String?) ?? '',
      joinedDate: joinedDate,
      status: json['is_active'] == false ? UserStatus.suspended : UserStatus.active,
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
