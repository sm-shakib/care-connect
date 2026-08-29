import 'package:bloc/bloc.dart';
import 'package:frontend/caregiver/data/repositories/booking_repository.dart';
import 'package:frontend/caregiver/models/booking_request.dart';
import 'package:frontend/core/repositories/auth_repository.dart';

import '../models/patient.dart';
import 'caregiver_dashboard_state.dart';

class CaregiverDashboardCubit extends Cubit<CaregiverDashboardState> {
  CaregiverDashboardCubit() : super(const CaregiverDashboardState()) {
    loadPatients();
  }

  final _bookingRepository = BookingRepository();
  final _authRepository = AuthRepository();

  Future<void> loadPatients() async {
    emit(state.copyWith(isLoading: true));
    try {
      final caregiverId = await _authRepository.getProfileId();
      if (caregiverId != null) {
        final requests =
            await _bookingRepository.getCaregiverBookings(caregiverId);

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final patients = requests
            .where((r) => r.status == BookingStatus.accepted)
            .map((r) {
          final isPast = r.endDate.isBefore(today);
          
          return Patient(
            id: r.elderId.toString(),
            name: r.elderName,
            age: 0, // Age not in booking schema
            location: r.elderAddress,
            status: isPast ? PatientCareStatus.previous : PatientCareStatus.active,
            schedule: r.timingLabel,
          );
        }).toList();

        emit(state.copyWith(allPatients: patients, isLoading: false));
      } else {
        emit(state.copyWith(allPatients: const [], isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(allPatients: const [], isLoading: false));
    }
  }

  void searchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
