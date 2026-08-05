import 'package:equatable/equatable.dart';

import 'caregiver_profile_model.dart';

enum CaregiverDetailLoadStatus { initial, loading, success, failure }

enum CaregiverDetailAction { none, statusChanged, removed, payoutRetried }

class CaregiverDetailState extends Equatable {
  const CaregiverDetailState({
    this.loadStatus = CaregiverDetailLoadStatus.initial,
    this.profile,
    this.errorMessage,
    this.action = CaregiverDetailAction.none,
  });

  final CaregiverDetailLoadStatus loadStatus;
  final CaregiverProfile? profile;
  final String? errorMessage;
  final CaregiverDetailAction action;

  bool get isLoading => loadStatus == CaregiverDetailLoadStatus.loading;
  bool get isSuspended => profile?.status == AccountStatus.suspended;

  CaregiverDetailState copyWith({
    CaregiverDetailLoadStatus? loadStatus,
    CaregiverProfile? profile,
    String? errorMessage,
    CaregiverDetailAction? action,
  }) {
    return CaregiverDetailState(
      loadStatus: loadStatus ?? this.loadStatus,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [loadStatus, profile, errorMessage, action];
}