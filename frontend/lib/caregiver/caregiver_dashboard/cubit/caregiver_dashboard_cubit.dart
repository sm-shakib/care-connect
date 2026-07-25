import 'package:bloc/bloc.dart';

import '../data/patient_dummy_data.dart';
import 'caregiver_dashboard_state.dart';

class CaregiverDashboardCubit extends Cubit<CaregiverDashboardState> {
  CaregiverDashboardCubit()
      : super(const CaregiverDashboardState()) {
    loadPatients();
  }

  void loadPatients() {
    emit(state.copyWith(allPatients: patientDummyData));
  }

  void searchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}