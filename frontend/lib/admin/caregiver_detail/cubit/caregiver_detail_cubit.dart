import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/repositories/admin_repository.dart';

import 'package:frontend/admin/caregiver_detail/cubit/caregiver_detail_state.dart';
import 'package:frontend/admin/caregiver_detail/cubit/caregiver_profile_model.dart';

/// Manages a single caregiver's profile: loading it, toggling status,
/// handling payouts, etc.
class CaregiverDetailCubit extends Cubit<CaregiverDetailState> {
  CaregiverDetailCubit({
    required this.userId,
    AdminRepository? adminRepository,
  })  : _adminRepository = adminRepository ?? AdminRepository(),
        super(const CaregiverDetailState());

  final String userId;
  final AdminRepository _adminRepository;

  Future<void> loadProfile() async {
    emit(state.copyWith(loadStatus: CaregiverDetailLoadStatus.loading));
    try {
      final caregiverResponse = await _adminRepository.getCaregiverApplication(
        int.parse(userId),
      );
      
      final profile = CaregiverProfile.fromJson(
        caregiverResponse,
        accountStatus: caregiverResponse['is_active'] == false 
            ? AccountStatus.suspended 
            : AccountStatus.active, 
      );

      emit(
        state.copyWith(
          loadStatus: CaregiverDetailLoadStatus.success,
          profile: profile,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          loadStatus: CaregiverDetailLoadStatus.failure,
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
          action: CaregiverDetailAction.statusChanged,
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

  /// Retries a failed payout.
  Future<void> retryPayout(String payoutId) async {
    final profile = state.profile;
    if (profile == null) return;

    final updatedPayouts = profile.recentPayouts.map((p) {
      if (p.id == payoutId) {
        return p.copyWith(status: PayoutStatus.processing);
      }
      return p;
    }).toList();

    emit(
      state.copyWith(
        profile: profile.copyWith(recentPayouts: updatedPayouts),
      ),
    );

    // Mocking an async process
    await Future<void>.delayed(const Duration(seconds: 1));

    final finalPayouts = updatedPayouts.map((p) {
      if (p.id == payoutId) {
        return p.copyWith(status: PayoutStatus.completed);
      }
      return p;
    }).toList();

    emit(
      state.copyWith(
        profile: profile.copyWith(recentPayouts: finalPayouts),
        action: CaregiverDetailAction.payoutRetried,
      ),
    );
  }

  /// Deletes the user.
  Future<void> removeUser() async {
    try {
      await _adminRepository.deleteUser(int.parse(userId));
      emit(state.copyWith(action: CaregiverDetailAction.removed));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to remove user.',
        ),
      );
    }
  }

  void consumeAction() {
    emit(state.copyWith(action: CaregiverDetailAction.none));
  }
}
