import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/repositories/admin_repository.dart';

import 'package:frontend/admin/family_member_detail/cubit/family_member_detail_state.dart';
import 'package:frontend/admin/family_member_detail/cubit/family_member_profile_model.dart';

/// Manages a single family member's profile: loading it, toggling status,
/// and removal.
class FamilyMemberDetailCubit extends Cubit<FamilyMemberDetailState> {
  FamilyMemberDetailCubit({
    required this.userId,
    AdminRepository? adminRepository,
  })  : _adminRepository = adminRepository ?? AdminRepository(),
        super(const FamilyMemberDetailState());

  final String userId;
  final AdminRepository _adminRepository;

  Future<void> loadProfile() async {
    emit(state.copyWith(loadStatus: FamilyMemberDetailLoadStatus.loading));
    try {
      final familyResponse = await _adminRepository.getFamilyDetail(
        int.parse(userId),
      );
      
      final profile = FamilyMemberProfile.fromJson(
        familyResponse,
        accountStatus: familyResponse['is_active'] == false 
            ? AccountStatus.suspended 
            : AccountStatus.active, 
      );

      emit(
        state.copyWith(
          loadStatus: FamilyMemberDetailLoadStatus.success,
          profile: profile,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          loadStatus: FamilyMemberDetailLoadStatus.failure,
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
          action: FamilyMemberDetailAction.statusChanged,
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
      emit(state.copyWith(action: FamilyMemberDetailAction.removed));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to remove user.',
        ),
      );
    }
  }

  void consumeAction() {
    emit(state.copyWith(action: FamilyMemberDetailAction.none));
  }
}
