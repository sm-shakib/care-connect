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
      final caregivers = List<Map<String, dynamic>>.from(
        (data as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item as Map)),
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

        final Map<CaregiverDocumentType, String> documents = {};
        if (map['documents'] != null) {
          final docsList = map['documents'] as List<dynamic>;
          for (final doc in docsList) {
            final docMap = doc as Map<String, dynamic>;
            final typeStr = docMap['document_type'] as String;
            final url = docMap['document_url'] as String;

            final type = CaregiverDocumentType.values.firstWhere(
              (e) => e.name == typeStr,
              orElse: () => CaregiverDocumentType.nationalId, // Fallback
            );
            documents[type] = url;
          }
        }

        final String id = ((map['id'] ?? map['user_id']) ?? '').toString();
        // Generate stable mock coordinates based on ID
        // final double lat = 23.8103 + (id.hashCode % 100) * 0.001;
        // final double lng = 90.4125 + (id.hashCode % 50) * 0.001;

        // double distance = 0;
        // if (userLat != null && userLng != null) {
        //   distance = _calculateDistance(userLat, userLng, lat, lng);
        // }

        return Caregiver(
          id: id,
          name: name,
          profession: 'Caregiver',
          imageUrl: (map['profile_image_url'] ?? '') as String,
          rating: 0,
          experience: ((map['experience_years'] ?? 0) as num).toInt(),
          distance: 0, // distance,
          hourlyRate: ((map['hourly_rate'] ?? 0) as num).toInt(),
          isVerified: (map['status'] ?? '') == 'verified',
          specialties: specialties,
          specializations: specializations,
          about: '',
          phone: (map['phone'] ?? '') as String,
          email: (map['email'] ?? '') as String,
          address: (map['address'] ?? '') as String,
          dateOfBirth: map['date_of_birth'] != null
              ? DateTime.tryParse(map['date_of_birth'] as String)
              : null,
          documents: documents,
          // latitude: lat,
          // longitude: lng,
        );
      }).toList();

      emit(
        state.copyWith(
          caregivers: caregivers,
          filteredCaregivers: caregivers,
        ),
      );
    } on Exception {
      emit(
        state.copyWith(
          caregivers: const <Caregiver>[],
          filteredCaregivers: const <Caregiver>[],
        ),
      );
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
