import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/user_management/cubit/user_management_filter.dart';
import 'package:frontend/admin/user_management/cubit/user_management_state.dart';
import 'package:frontend/admin/user_management/cubit/user_model.dart';
import 'package:frontend/core/repositories/admin_repository.dart';

/// Manages the user management list: loading, searching and filtering.
class UserManagementCubit extends Cubit<UserManagementState> {
  UserManagementCubit({AdminRepository? adminRepository})
      : _adminRepository = adminRepository ?? AdminRepository(),
        super(const UserManagementState());

  final AdminRepository _adminRepository;

  Future<void> loadUsers() async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      final roleFilter = _mapFilterToRole(state.filter);
      final usersData = await _adminRepository.getUsers(role: roleFilter);

      final users = usersData
          .map((dynamic json) => UserAccount.fromJson(json as Map<String, dynamic>))
          .toList();

      emit(
        state.copyWith(
          status: UserManagementStatus.success,
          users: users,
        ),
      );
    } on Exception catch (e) {
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

  Future<void> filterChanged(UserManagementFilter filter) async {
    emit(state.copyWith(filter: filter));
    await loadUsers();
  }

  String? _mapFilterToRole(UserManagementFilter filter) {
    switch (filter) {
      case UserManagementFilter.all:
        return null;
      case UserManagementFilter.elderly:
        return 'elder';
      case UserManagementFilter.family:
        return 'family';
      case UserManagementFilter.caregiver:
        return 'caregiver';
      case UserManagementFilter.admin:
        return 'admin';
    }
  }

  Future<void> toggleUserStatus(UserAccount user) async {
    final newIsActive = user.status == UserStatus.suspended;
    try {
      await _adminRepository.updateUserStatus(int.parse(user.id), newIsActive);
      await loadUsers(); // Refresh list
    } on Exception catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to update user status.',
        ),
      );
    }
  }
}
