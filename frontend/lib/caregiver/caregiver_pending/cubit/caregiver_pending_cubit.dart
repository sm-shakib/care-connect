import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver/data/repositories/caregiver_repository.dart';

part 'caregiver_pending_state.dart';

class CaregiverPendingCubit extends Cubit<CaregiverPendingState> {
  CaregiverPendingCubit({CaregiverRepository? repository})
      : _repository = repository ?? CaregiverRepository(),
        super(const CaregiverPendingState()) {
    refreshStatus();
  }

  final CaregiverRepository _repository;

  Future<void> refreshStatus() async {
    emit(state.copyWith(status: CaregiverPendingStatus.loading));
    try {
      final profile = await _repository.getMyProfile();
      final status = profile['status'] as String?;
      final notes = profile['admin_notes'] as String?;

      if (status == 'verified') {
        emit(state.copyWith(status: CaregiverPendingStatus.verified));
      } else {
        emit(state.copyWith(
          status: CaregiverPendingStatus.success,
          adminNotes: notes,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CaregiverPendingStatus.failure,
        errorMessage: 'Failed to refresh status. Please try again.',
      ));
    }
  }
}
