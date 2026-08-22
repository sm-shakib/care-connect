import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/admin/caregiver_detail/cubit/caregiver_detail_state.dart';
import 'package:frontend/admin/caregiver_detail/cubit/caregiver_profile_model.dart';

/// Manages a single caregiver's profile: loading it, the two admin
/// actions (suspend/reactivate, remove), and retrying a failed payout.
///
/// NOTE: [loadProfile] looks [userId] up in a mock map below. Wire it
/// up to your FastAPI endpoints (e.g. `GET /admin/caregivers/{id}`,
/// `PATCH /admin/users/{id}/status`, `DELETE /admin/users/{id}`, and
/// `POST /admin/payouts/{id}/retry`) when ready.
class CaregiverDetailCubit extends Cubit<CaregiverDetailState> {
  CaregiverDetailCubit({required this.userId})
      : super(const CaregiverDetailState());

  final String userId;

  Future<void> loadProfile() async {
    emit(state.copyWith(loadStatus: CaregiverDetailLoadStatus.loading));
    try {
      // TODO(careconnect): replace with repository call to FastAPI
      // backend, fetching by `userId`.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final profile = _mockProfiles[userId] ?? _mockProfiles.values.first;
      emit(
        state.copyWith(
          loadStatus: CaregiverDetailLoadStatus.success,
          profile: profile,
        ),
      );
    } on Exception catch (_) {
      emit(
        state.copyWith(
          loadStatus: CaregiverDetailLoadStatus.failure,
          errorMessage: 'Unable to load this profile. Please try again.',
        ),
      );
    }
  }

  /// Toggles between active/suspended.
  // TODO(careconnect): call `PATCH /admin/users/{id}/status` instead
  // of just updating local state.
  Future<void> toggleAccountStatus() async {
    final profile = state.profile;
    if (profile == null) return;
    final newStatus = profile.status == AccountStatus.active
        ? AccountStatus.suspended
        : AccountStatus.active;
    emit(
      state.copyWith(
        profile: profile.copyWith(status: newStatus),
        action: CaregiverDetailAction.statusChanged,
      ),
    );
  }

  // TODO(careconnect): call `DELETE /admin/users/{id}` instead of just
  // flagging local state. The view confirms this destructive action
  // with the admin before calling it.
  Future<void> removeUser() async {
    emit(state.copyWith(action: CaregiverDetailAction.removed));
  }

  /// Retries a failed payout — flips it to `processing` locally.
  //
  // TODO(careconnect): call `POST /admin/payouts/{id}/retry` instead
  // of just updating local state.
  Future<void> retryPayout(String payoutId) async {
    final profile = state.profile;
    if (profile == null) return;
    final updatedPayouts = profile.recentPayouts.map((payout) {
      if (payout.id != payoutId) return payout;
      return payout.copyWith(status: PayoutStatus.processing);
    }).toList();
    emit(
      state.copyWith(
        profile: profile.copyWith(recentPayouts: updatedPayouts),
        action: CaregiverDetailAction.payoutRetried,
      ),
    );
  }

  /// Clears the one-shot [CaregiverDetailState.action] after the view
  /// has reacted to it, so it doesn't refire.
  void consumeAction() {
    emit(state.copyWith(action: CaregiverDetailAction.none));
  }

  static const Map<String, CaregiverProfile> _mockProfiles = {
    // Matches user_management's mock caregiver (id '2', Fatema Begum).
    '2': CaregiverProfile(
      id: '2',
      name: 'Fatema Begum',
      avatarUrl:
          'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      status: AccountStatus.active,
      title: 'Caregiver',
      isVerified: true,
      rating: 4.9,
      reviewCount: 42,
      gender: 'Female',
      experienceYears: 8,
      availability: 'Full-time',
      hourlyRate: 350,
      phone: '+880 1812-987654',
      email: 'fatema.begum@careconnect.com',
      address: 'House 22, Road 8, Banani, Dhaka',
      specializations: [
        SpecializationTag(label: 'Dementia Care', isPrimary: true),
      ],
      verificationChecklist: [
        VerificationChecklistItem(label: 'National ID', isVerified: true),
        VerificationChecklistItem(
          label: 'Professional Certificate',
          isVerified: true,
        ),
        VerificationChecklistItem(
          label: 'Police Clearance',
          isVerified: true,
        ),
      ],
      documents: [
        CaregiverDocument(
          title: 'National ID',
          subtitle: 'National ID Card',
          previewUrl:
              'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
          iconName: 'badge',
        ),
        CaregiverDocument(
          title: 'Professional Certificate',
          subtitle: 'Nursing License',
          previewUrl:
              'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
          iconName: 'description',
        ),
      ],
      recentBookings: [
        CaregiverBookingSummary(
          id: 'BK-3082',
          elderlyUserName: 'Abdul Karim',
          dateRangeLabel: 'Oct 20 - 25',
          statusLabel: 'Ongoing',
        ),
        CaregiverBookingSummary(
          id: 'BK-3081',
          elderlyUserName: 'Rahima Khatun',
          dateRangeLabel: 'Oct 12 - 15',
          statusLabel: 'Upcoming',
        ),
      ],
      totalEarned: 14250,
      pendingAmount: 4500,
      thisMonthAmount: 2100,
      nextPayoutDateLabel: 'Oct 30',
      recentPayouts: [
        Payout(
          id: 'payout-1',
          periodLabel: 'BK-3082 - Elderly Companion Care',
          amount: 4500,
          method: 'Bank Transfer',
          status: PayoutStatus.pending,
          dateLabel: 'Scheduled Oct 30',
        ),
        Payout(
          id: 'payout-2',
          periodLabel: 'BK-3081 - Post-Op Recovery',
          amount: 2100,
          method: 'Bkash',
          status: PayoutStatus.completed,
          dateLabel: 'Paid Oct 1',
        ),
        Payout(
          id: 'payout-3',
          periodLabel: 'BK-3079 - General Care',
          amount: 3000,
          method: 'Bkash',
          status: PayoutStatus.failed,
          dateLabel: 'Attempted Sep 16',
        ),
      ],
    ),
  };
}
