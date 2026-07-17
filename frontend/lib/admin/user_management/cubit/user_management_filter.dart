import 'user_model.dart';

/// Filter chip options shown at the top of the user management list.
enum UserManagementFilter { all, elderly, family, caregiver, admin }

extension UserManagementFilterX on UserManagementFilter {
  String get label {
    switch (this) {
      case UserManagementFilter.all:
        return 'All';
      case UserManagementFilter.elderly:
        return 'Elderly';
      case UserManagementFilter.family:
        return 'Family';
      case UserManagementFilter.caregiver:
        return 'Caregiver';
      case UserManagementFilter.admin:
        return 'Admin';
    }
  }

  /// Whether a user with [role] should be shown under this filter.
  bool matches(UserRole role) {
    switch (this) {
      case UserManagementFilter.all:
        return true;
      case UserManagementFilter.elderly:
        return role == UserRole.elderly;
      case UserManagementFilter.family:
        return role == UserRole.family;
      case UserManagementFilter.caregiver:
        return role == UserRole.caregiver;
      case UserManagementFilter.admin:
        return role == UserRole.admin;
    }
  }
}