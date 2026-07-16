import 'package:flutter_bloc/flutter_bloc.dart';

import 'caregiver_model.dart';
import 'caregiver_verification_filter.dart';
import 'caregiver_verification_state.dart';

/// Manages the caregiver verification list: loading, searching and filtering.
///
/// NOTE: [loadCaregivers] currently returns mock data. Swap the body of
/// that method for a call into your FastAPI caregiver-verification
/// repository/endpoint when it's ready.
class CaregiverVerificationCubit extends Cubit<CaregiverVerificationState> {
  CaregiverVerificationCubit() : super(const CaregiverVerificationState());

  Future<void> loadCaregivers() async {
    emit(state.copyWith(status: CaregiverVerificationStatus.loading));
    try {
      // TODO(careconnect): replace with repository call to FastAPI backend.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(
        state.copyWith(
          status: CaregiverVerificationStatus.success,
          caregivers: _mockCaregivers,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CaregiverVerificationStatus.failure,
          errorMessage: 'Unable to load caregivers. Please try again.',
        ),
      );
    }
  }

  void searchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void filterChanged(CaregiverVerificationFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  static const List<CaregiverModel> _mockCaregivers = [
    CaregiverModel(
      id: '1',
      name: 'Adib Khan',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      yearsExperience: 8,
      specialty: 'Dementia Care',
      hourlyRate: 300,
      status: VerificationStatus.pending,
    ),
    CaregiverModel(
      id: '2',
      name: 'Shakib Khan',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      yearsExperience: 12,
      specialty: 'Post-Op Recovery',
      hourlyRate: 500,
      status: VerificationStatus.verified,
    ),
    CaregiverModel(
      id: '3',
      name: 'Shihab Khan',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      yearsExperience: 3,
      specialty: 'General Care',
      hourlyRate: 1000,
      status: VerificationStatus.rejected,
    ),
    CaregiverModel(
      id: '4',
      name: 'Mafia Messi',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      yearsExperience: 20,
      specialty: 'Palliative Care',
      hourlyRate: 1000,
      status: VerificationStatus.verified,
    ),
  ];
}