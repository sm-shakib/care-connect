part of 'caregiver_pending_cubit.dart';

enum CaregiverPendingStatus { initial, loading, success, failure, verified }

class CaregiverPendingState {
  const CaregiverPendingState({
    this.status = CaregiverPendingStatus.initial,
    this.adminNotes,
    this.errorMessage,
  });

  final CaregiverPendingStatus status;
  final String? adminNotes;
  final String? errorMessage;

  CaregiverPendingState copyWith({
    CaregiverPendingStatus? status,
    String? adminNotes,
    String? errorMessage,
  }) {
    return CaregiverPendingState(
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
