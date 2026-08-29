import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/repositories/admin_repository.dart';

import 'package:frontend/admin/elderly_detail/cubit/elderly_detail_state.dart';
import 'package:frontend/admin/elderly_detail/cubit/elderly_profile_model.dart';

/// Manages a single elderly user's profile: loading it, and the two
/// admin actions (suspend/reactivate, remove).
class ElderlyDetailCubit extends Cubit<ElderlyDetailState> {
  ElderlyDetailCubit({
    required this.userId,
    AdminRepository? adminRepository,
  })  : _adminRepository = adminRepository ?? AdminRepository(),
        super(const ElderlyDetailState());

  final String userId;
  final AdminRepository _adminRepository;

  Future<void> loadProfile() async {
    emit(state.copyWith(loadStatus: ElderlyDetailLoadStatus.loading));
    try {
      final userResponse = await _adminRepository.getElderDetail(
        int.parse(userId),
      );
      
      final profile = ElderlyProfile.fromJson(
        userResponse,
        accountStatus: userResponse['is_active'] == false 
            ? AccountStatus.suspended 
            : AccountStatus.active, 
      );

      emit(
        state.copyWith(
          loadStatus: ElderlyDetailLoadStatus.success,
          profile: profile,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          loadStatus: ElderlyDetailLoadStatus.failure,
          errorMessage: 'Unable to load this profile. Please try again.',
        ),
      );
    }
  }

  /// Toggles between active/suspended.
  Future<void> toggleAccountStatus() async {
    final profile = state.profile;
    if (profile == null) return;
    
    final newIsActive = profile.status == AccountStatus.suspended;
    try {
      await _adminRepository.updateUserStatus(int.parse(userId), newIsActive);
      
      final newStatus = newIsActive ? AccountStatus.active : AccountStatus.suspended;
      emit(
        state.copyWith(
          profile: profile.copyWith(status: newStatus),
          action: ElderlyDetailAction.statusChanged,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to update account status.',
        ),
      );
    }
  }

  /// Deletes the user.
  Future<void> removeUser() async {
    try {
      await _adminRepository.deleteUser(int.parse(userId));
      emit(state.copyWith(action: ElderlyDetailAction.removed));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to remove user.',
        ),
      );
    }
  }

  /// Clears the one-shot [ElderlyDetailState.action] after the view has
  /// reacted to it, so it doesn't refire.
  void consumeAction() {
    emit(state.copyWith(action: ElderlyDetailAction.none));
  }
}
