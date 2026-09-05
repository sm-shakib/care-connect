import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/caregiver_signup/caregiver_signup.dart';
import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/caregiver/data/repositories/caregiver_repository.dart';

part 'caregiver_profile_state.dart';

class CaregiverProfileCubit extends Cubit<CaregiverProfileState> {
  final CaregiverRepository _repository;

  CaregiverProfileCubit({CaregiverRepository? repository})
      : _repository = repository ?? CaregiverRepository(),
        super(const CaregiverProfileState()) {
    _lastSaved = state;
    loadProfile();
  }

  /// Snapshot to revert to if the user cancels an edit session.
  late CaregiverProfileState _lastSaved;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: CaregiverProfileStatus.loading));
    try {
      final profile = await _repository.getMyProfile();
      debugPrint('DEBUG: Caregiver profile fetched: $profile');

      final dobStr = profile['date_of_birth'] as String?;
      final dob = dobStr != null ? DateTime.tryParse(dobStr) : null;

      final Map<CaregiverDocumentType, String> documents = {};
      if (profile['documents'] != null) {
        final docsList = profile['documents'] as List<dynamic>;
        for (final doc in docsList) {
          final docMap = doc as Map<String, dynamic>;
          final typeStr = docMap['document_type'] as String;
          final url = docMap['document_url'] as String;

          final type = CaregiverDocumentType.values.firstWhere(
            (e) => e.name == typeStr,
            orElse: () => CaregiverDocumentType.nationalId,
          );
          documents[type] = url;
        }
      }

      final newState = state.copyWith(
        status: CaregiverProfileStatus.success,
        name: profile['name'] as String? ?? '',
        email: profile['email'] as String? ?? '',
        phone: profile['phone'] as String? ?? '',
        address: profile['address'] as String? ?? '',
        gender: _parseGender(profile['gender'] as String?),
        dateOfBirth: dob,
        specializations: profile['specializations'] as String? ?? '',
        availabilityType: _parseAvailability(profile['availability_type'] as String?),
        hourlyRate: (profile['hourly_rate'] ?? '').toString(),
        experienceYears: (profile['experience_years'] ?? '').toString(),
        profileImageUrl: profile['profile_image_url'] as String? ?? '',
        documents: documents,
        // TODO: Map earnings data when backend supports it
        totalEarningsThisMonth: (profile['total_earnings'] as num? ?? 0).toDouble(),
      );

      _lastSaved = newState;
      emit(newState);
    } catch (e) {
      debugPrint('CaregiverProfileCubit.loadProfile error: $e');
      emit(state.copyWith(
        status: CaregiverProfileStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Gender? _parseGender(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase();
    if (normalized == 'male') return Gender.male;
    if (normalized == 'female') return Gender.female;
    return null;
  }

  AvailabilityType? _parseAvailability(String? value) {
    if (value == null) return null;
    return AvailabilityType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AvailabilityType.fullTime,
    );
  }

  void startEditing() {
    _lastSaved = state;
    emit(state.copyWith(isEditing: true, editSessionId: state.editSessionId + 1));
  }

  void cancelEditing() {
    emit(_lastSaved.copyWith(isEditing: false, editSessionId: state.editSessionId + 1));
  }

  Future<void> saveChanges() async {
    emit(state.copyWith(isSaving: true));
    try {
      final dobStr = state.dateOfBirth != null
          ? "${state.dateOfBirth!.year}-${state.dateOfBirth!.month.toString().padLeft(2, '0')}-${state.dateOfBirth!.day.toString().padLeft(2, '0')}"
          : null;

      await _repository.updateProfile({
        'name': state.name,
        'phone': state.phone,
        'address': state.address,
        'date_of_birth': dobStr,
        'gender': state.gender?.name ?? 'female',
        'specializations': state.specializations,
        'availability_type': state.availabilityType?.name,
        'hourly_rate': double.tryParse(state.hourlyRate) ?? 0.0,
        'experience_years': int.tryParse(state.experienceYears) ?? 0,
      });
      _lastSaved = state.copyWith(isEditing: false, isSaving: false);
      emit(_lastSaved);
    } catch (e) {
      debugPrint('CaregiverProfileCubit.saveChanges error: $e');
      emit(state.copyWith(isSaving: false));
    }
  }

  void nameChanged(String value) => emit(state.copyWith(name: value));
  void phoneChanged(String value) => emit(state.copyWith(phone: value));
  void addressChanged(String value) => emit(state.copyWith(address: value));
  void genderChanged(Gender? value) => emit(state.copyWith(gender: value));
  void dateOfBirthChanged(DateTime value) =>
      emit(state.copyWith(dateOfBirth: value));
  void specializationsChanged(String value) =>
      emit(state.copyWith(specializations: value));
  void availabilityTypeChanged(AvailabilityType? value) =>
      emit(state.copyWith(availabilityType: value));
  void hourlyRateChanged(String value) => emit(state.copyWith(hourlyRate: value));
  void experienceYearsChanged(String value) =>
      emit(state.copyWith(experienceYears: value));
  void profileImagePicked(Uint8List bytes) =>
      emit(state.copyWith(profileImageBytes: bytes));

  void logOut() {
    // TODO: clear auth session/tokens once real auth exists.
  }
}
