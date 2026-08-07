import 'package:flutter_bloc/flutter_bloc.dart';

import 'user_management_filter.dart';
import 'user_management_state.dart';
import 'user_model.dart';

/// Manages the user management list: loading, searching and filtering.
///
/// NOTE: [loadUsers] currently returns mock data. Swap the body of that
/// method for a call into your FastAPI user-management
/// repository/endpoint when it's ready.
class UserManagementCubit extends Cubit<UserManagementState> {
  UserManagementCubit() : super(const UserManagementState());

  Future<void> loadUsers() async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      // TODO(careconnect): replace with repository call to FastAPI backend.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(
        state.copyWith(
          status: UserManagementStatus.success,
          users: _mockUsers,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: UserManagementStatus.failure,
          errorMessage: 'Unable to load users. Please try again.',
        ),
      );
    }
  }

  void searchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void filterChanged(UserManagementFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  static final List<UserAccount> _mockUsers = [
    UserAccount(
      id: '1',
      name: 'Abdul Karim',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      role: UserRole.elderly,
      phone: '+880 1712-345678',
      joinedDate: DateTime(2023, 10, 12),
      status: UserStatus.active,
    ),
    UserAccount(
      id: '2',
      name: 'Fatema Begum',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      role: UserRole.caregiver,
      phone: '+880 1812-987654',
      joinedDate: DateTime(2023, 11, 5),
      status: UserStatus.active,
    ),
    UserAccount(
      id: '3',
      name: 'Rafiqul Islam',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      role: UserRole.family,
      phone: '+880 1912-112233',
      joinedDate: DateTime(2024, 1, 20),
      status: UserStatus.active,
    ),
    /*UserAccount(
      id: '4',
      name: 'Nusrat Jahan',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      role: UserRole.admin,
      phone: '+880 1611-556677',
      joinedDate: DateTime(2024, 2, 14),
      status: UserStatus.active,
    ),*/
  ];
}