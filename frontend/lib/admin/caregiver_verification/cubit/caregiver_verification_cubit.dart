import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/repositories/admin_repository.dart';
import 'caregiver_model.dart';
import 'caregiver_verification_filter.dart';
import 'caregiver_verification_state.dart';

/// Manages the caregiver verification list: loading, searching and filtering.
class CaregiverVerificationCubit extends Cubit<CaregiverVerificationState> {
  CaregiverVerificationCubit({AdminRepository? adminRepository})
      : _adminRepository = adminRepository ?? AdminRepository(),
        super(const CaregiverVerificationState());

  final AdminRepository _adminRepository;

  Future<void> loadCaregivers() async {
    emit(state.copyWith(status: CaregiverVerificationStatus.loading));
    try {
      final filterStatus = state.filter == CaregiverVerificationFilter.all
          ? null
          : state.filter.name;
      final results = await _adminRepository.getCaregiversForVerification(
        status: filterStatus,
      );

      final caregivers = results.map((data) {
        return CaregiverModel(
          id: data['id'].toString(),
          name: data['name'] as String,
          avatarUrl: data['profile_image_url'] as String? ??
              'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
          yearsExperience: data['experience_years'] as int,
          specialty: data['specializations'] as String,
          hourlyRate: (data['hourly_rate'] as num).toDouble(),
          status: _mapStatus(data['status'] as String),
        );
      }).toList();

      emit(
        state.copyWith(
          status: CaregiverVerificationStatus.success,
          caregivers: caregivers,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CaregiverVerificationStatus.failure,
          errorMessage: 'Unable to load caregivers. Please try again.',
        ),
      );
    }
  }

  VerificationStatus _mapStatus(String status) {
    switch (status) {
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'pending':
      default:
        return VerificationStatus.pending;
    }
  }

  void searchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void filterChanged(CaregiverVerificationFilter filter) {
    emit(state.copyWith(filter: filter));
  }
}
