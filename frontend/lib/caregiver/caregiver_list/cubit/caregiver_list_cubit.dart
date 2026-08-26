import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:frontend/caregiver/caregiver_list/cubit/caregiver_list_state.dart';
import 'package:frontend/caregiver/models/caregiver.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';

class CaregiverListCubit extends Cubit<CaregiverListState> {
  CaregiverListCubit() : super(const CaregiverListState()) {
    unawaited(loadCaregivers());
  }

  Future<void> loadCaregivers() async {
    try {
      final response = await ApiClient().get<List<dynamic>>(ApiConstants.caregivers);
      final data = response.data ?? const <dynamic>[];
      final caregivers = List<Map<String, dynamic>>.from(
        (data as List<dynamic>).map((item) => Map<String, dynamic>.from(item as Map)),
      ).map((map) {
        final String name = (map['name'] ?? '') as String;
        final String specializations = (map['specializations'] ?? '') as String;
        final List<String> specialties = specializations.isEmpty
            ? const <String>[]
            : specializations
                .split(',')
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toList();

        return Caregiver(
          id: ((map['id'] ?? map['user_id']) ?? '').toString(),
          name: name,
          profession: 'Caregiver',
          imageUrl: (map['profile_image_url'] ?? '') as String,
          rating: 0,
          experience: ((map['experience_years'] ?? 0) as num).toInt(),
          distance: 0,
          hourlyRate: ((map['hourly_rate'] ?? 0) as num).toInt(),
          isVerified: (map['status'] ?? '') == 'verified',
          specialties: specialties,
          specializations: specializations,
          about: '',
          phone: (map['phone'] ?? '') as String,
          email: (map['email'] ?? '') as String,
          address: (map['address'] ?? '') as String,
          dateOfBirth: null,
        );
      }).toList();

      emit(
        state.copyWith(
          caregivers: caregivers,
          filteredCaregivers: caregivers,
        ),
      );
    } on Exception {
      emit(state.copyWith(caregivers: const <Caregiver>[], filteredCaregivers: const <Caregiver>[]));
    }
  }

  void searchCaregiver(String query) {
    final lowerQuery = query.toLowerCase();

    final results = state.caregivers.where((caregiver) {
      return caregiver.name.toLowerCase().contains(lowerQuery) ||
          caregiver.profession.toLowerCase().contains(lowerQuery) ||
          caregiver.specialties.any(
            (specialty) => specialty.toLowerCase().contains(lowerQuery),
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
