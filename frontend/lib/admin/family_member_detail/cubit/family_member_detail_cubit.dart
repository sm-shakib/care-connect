import 'package:flutter_bloc/flutter_bloc.dart';

import 'family_member_detail_state.dart';
import 'family_member_profile_model.dart';

/// Manages a single family member's profile: loading it, and the two
/// admin actions (suspend/reactivate, remove).
///
/// NOTE: [loadProfile] looks [userId] up in a mock map below. Wire it
/// up to your FastAPI endpoints (e.g. `GET /admin/family/{id}`,
/// `PATCH /admin/users/{id}/status`, `DELETE /admin/users/{id}`) when
/// ready.
class FamilyMemberDetailCubit extends Cubit<FamilyMemberDetailState> {
  FamilyMemberDetailCubit({required this.userId})
      : super(const FamilyMemberDetailState());

  final String userId;

  Future<void> loadProfile() async {
    emit(state.copyWith(loadStatus: FamilyMemberDetailLoadStatus.loading));
    try {
      // TODO(careconnect): replace with repository call to FastAPI
      // backend, fetching by `userId`.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final profile = _mockProfiles[userId] ?? _mockProfiles.values.first;
      emit(
        state.copyWith(
          loadStatus: FamilyMemberDetailLoadStatus.success,
          profile: profile,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loadStatus: FamilyMemberDetailLoadStatus.failure,
          errorMessage: 'Unable to load this profile. Please try again.',
        ),
      );
    }
  }

  /// Toggles between active/suspended.
  ///
  /// TODO(careconnect): call `PATCH /admin/users/{id}/status` instead
  /// of just updating local state.
  Future<void> toggleAccountStatus() async {
    final profile = state.profile;
    if (profile == null) return;
    final newStatus = profile.status == AccountStatus.active
        ? AccountStatus.suspended
        : AccountStatus.active;
    emit(
      state.copyWith(
        profile: profile.copyWith(status: newStatus),
        action: FamilyMemberDetailAction.statusChanged,
      ),
    );
  }

  /// TODO(careconnect): call `DELETE /admin/users/{id}` instead of just
  /// flagging local state. The view is responsible for confirming this
  /// destructive action with the admin before calling it, and for
  /// navigating back afterward.
  Future<void> removeUser() async {
    emit(state.copyWith(action: FamilyMemberDetailAction.removed));
  }

  /// Clears the one-shot [FamilyMemberDetailState.action] after the
  /// view has reacted to it, so it doesn't refire.
  void consumeAction() {
    emit(state.copyWith(action: FamilyMemberDetailAction.none));
  }

  static const Map<String, FamilyMemberProfile> _mockProfiles = {
    // Matches user_management's mock family member (id '3', Rafiqul
    // Islam), reciprocally linked to elderly_detail's Abdul Karim
    // (id '1') — he's Rafiqul's father there, and Rafiqul is listed as
    // Abdul Karim's son/primary contact on that side.
    '3': FamilyMemberProfile(
      id: '3',
      name: 'Rafiqul Islam',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      status: AccountStatus.active,
      gender: 'Male',
      age: 45,
      phone: '+880 1912-112233',
      email: 'rafiqul.islam@email.com',
      address: 'House 7, Sector 11, Uttara, Dhaka',
      linkedElderlyUsers: [
        LinkedElderlyUser(
          id: '1',
          name: 'Abdul Karim',
          avatarUrl:
          'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
          relationship: 'Father',
          isPrimaryContact: false,
        ),
      ],
      alertPreferences: [
        AlertPreference(label: 'Medicine Alerts', isEnabled: true),
        AlertPreference(label: 'SOS Alerts', isEnabled: true),
        AlertPreference(label: 'Booking Updates', isEnabled: true),
      ],
    ),
  };
}