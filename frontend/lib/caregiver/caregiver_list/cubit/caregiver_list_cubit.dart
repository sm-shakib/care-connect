import 'package:bloc/bloc.dart';

import '../../data/caregiver_dummy_data.dart';
import '../../models/caregiver.dart';
import 'caregiver_list_state.dart';

class CaregiverListCubit extends Cubit<CaregiverListState> {
  CaregiverListCubit() : super(const CaregiverListState()) {
    loadCaregivers();
  }

  void loadCaregivers() {
    emit(
      state.copyWith(
        caregivers: caregiverList,
        filteredCaregivers: caregiverList,
      ),
    );
  }

  void searchCaregiver(String query) {
    final lowerQuery = query.toLowerCase();

    final results = state.caregivers.where((caregiver) {
      return caregiver.name.toLowerCase().contains(lowerQuery) ||
          caregiver.profession.toLowerCase().contains(lowerQuery) ||
          caregiver.specialties.any(
                (specialty) =>
                specialty.toLowerCase().contains(lowerQuery),
          );
    }).toList();

    emit(
      state.copyWith(
        searchText: query,
        filteredCaregivers: results,
      ),
    );
  }

  void filterCaregivers(String filter) {
    if (filter == 'All') {
      emit(
        state.copyWith(
          selectedFilter: filter,
          filteredCaregivers: state.caregivers,
        ),
      );
      return;
    }

    final filtered = state.caregivers.where((caregiver) {
      return caregiver.specialties.contains(filter);
    }).toList();

    emit(
      state.copyWith(
        selectedFilter: filter,
        filteredCaregivers: filtered,
      ),
    );
  }
}