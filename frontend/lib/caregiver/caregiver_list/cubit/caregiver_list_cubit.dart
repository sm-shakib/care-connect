import 'dart:async';
// import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:frontend/caregiver/caregiver_list/cubit/caregiver_list_state.dart';
import 'package:frontend/caregiver/models/caregiver.dart';
import 'package:frontend/caregiver_signup/caregiver_signup.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';

class CaregiverListCubit extends Cubit<CaregiverListState> {
  CaregiverListCubit() : super(const CaregiverListState()) {
    unawaited(loadCaregivers());
  }

  Future<void> loadCaregivers(/* {double? userLat, double? userLng} */) async {
    try {
      final response =
          await ApiClient().get<List<dynamic>>(ApiConstants.caregivers);
      final data = response.data ?? const <dynamic>[];
      final allCaregivers = List<Map<String, dynamic>>.from(
        (data as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item as Map)),
      ).map(Caregiver.fromJson).toList();

      emit(state.copyWith(allCaregivers: allCaregivers));
      _applyExclusion();
    } on Exception {
      emit(
        state.copyWith(
          allCaregivers: const <Caregiver>[],
          caregivers: const <Caregiver>[],
          filteredCaregivers: const <Caregiver>[],
        ),
      );
    }
  }

  void _applyExclusion() {
    final caregivers = state.allCaregivers
        .where((c) => !state.excludedIds.contains(c.id))
        .toList();

    emit(
      state.copyWith(
        caregivers: caregivers,
        filteredCaregivers: caregivers,
      ),
    );
    
    // Also re-apply search and filter if they were active
    if (state.searchText.isNotEmpty) {
      searchCaregiver(state.searchText);
    }
    if (state.selectedFilter != 'All') {
      filterCaregivers(state.selectedFilter);
    }
  }

  /*
  void updateReferenceLocation(double userLat, double userLng) {
    final updatedCaregivers = state.caregivers.map((c) {
      final dist = _calculateDistance(userLat, userLng, c.latitude, c.longitude);
      return c.copyWith(distance: dist);
    }).toList();

    final updatedFiltered = state.filteredCaregivers.map((c) {
      final dist = _calculateDistance(userLat, userLng, c.latitude, c.longitude);
      return c.copyWith(distance: dist);
    }).toList();

    emit(
      state.copyWith(
        caregivers: updatedCaregivers,
        filteredCaregivers: updatedFiltered,
      ),
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;
    return double.parse(distance.toStringAsFixed(2));
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }
  */

  void setExcludedIds(List<String> excludedIds) {
    emit(state.copyWith(excludedIds: excludedIds));
    _applyExclusion();
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
