import 'package:flutter_bloc/flutter_bloc.dart';

import 'elderly_detail_state.dart';
import 'elderly_profile_model.dart';

/// Manages a single elderly user's profile: loading it, and the two
/// admin actions (suspend/reactivate, remove).
///
/// NOTE: [loadProfile] looks [userId] up in a mock map below. Wire it
/// up to your FastAPI endpoints (e.g. `GET /admin/elderly/{id}`,
/// `PATCH /admin/users/{id}/status`, `DELETE /admin/users/{id}`) when
/// ready.
class ElderlyDetailCubit extends Cubit<ElderlyDetailState> {
  ElderlyDetailCubit({required this.userId})
      : super(const ElderlyDetailState());

  final String userId;

  Future<void> loadProfile() async {
    emit(state.copyWith(loadStatus: ElderlyDetailLoadStatus.loading));
    try {
      // TODO(careconnect): replace with repository call to FastAPI
      // backend, fetching by `userId`.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final profile = _mockProfiles[userId] ?? _mockProfiles.values.first;
      emit(
        state.copyWith(
          loadStatus: ElderlyDetailLoadStatus.success,
          profile: profile,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loadStatus: ElderlyDetailLoadStatus.failure,
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
        action: ElderlyDetailAction.statusChanged,
      ),
    );
  }

  /// TODO(careconnect): call `DELETE /admin/users/{id}` instead of just
  /// flagging local state. The view is responsible for confirming this
  /// destructive action with the admin before calling it, and for
  /// navigating back afterward.
  Future<void> removeUser() async {
    emit(state.copyWith(action: ElderlyDetailAction.removed));
  }

  /// Clears the one-shot [ElderlyDetailState.action] after the view has
  /// reacted to it, so it doesn't refire.
  void consumeAction() {
    emit(state.copyWith(action: ElderlyDetailAction.none));
  }

  static const Map<String, ElderlyProfile> _mockProfiles = {
    '1': ElderlyProfile(
      id: '1',
      name: 'Abdul Karim',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      status: AccountStatus.active,
      gender: 'Male',
      age: 72,
      phone: '+880 1712-345678',
      email: 'abdul.karim@email.com',
      address: 'House 12, Road 5, Dhanmondi, Dhaka',
      healthCondition:
      'Diabetes Type 2, Hypertension. Requires assistance with '
          'mobility. No known allergies.',
      linkedFamilyMembers: [
        LinkedFamilyMember(
          name: 'Rafiqul Islam',
          avatarUrl:
          'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
          relationship: 'Son',
          isPrimaryContact: true,
        ),
      ],
      recentSosEvents: [
        SosEventSummary(
          dateLabel: 'Oct 12, 2023',
          timeLabel: '08:45 AM',
          status: SosEventStatus.resolved,
        ),
      ],
    ),
  };
}