import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/family/data/repositories/family_profile_repository.dart';

part 'family_profile_state.dart';

class FamilyProfileCubit extends Cubit<FamilyProfileState> {
  final FamilyProfileRepository _repository;

  FamilyProfileCubit(this._repository)
      : super(const FamilyProfileState()) {
    _lastSaved = state;
    loadProfile();
  }

  late FamilyProfileState _lastSaved;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: FamilyProfileStatus.loading));
    try {
      final profile = await _repository.getMyProfile();
      debugPrint('DEBUG: Family profile fetched: $profile');
      
      final dobStr = profile['date_of_birth'] as String?;
      final dob = dobStr != null ? DateTime.tryParse(dobStr) : null;
      
      final newState = state.copyWith(
        status: FamilyProfileStatus.success,
        name: profile['name'] as String? ?? '',
        email: profile['email'] as String? ?? '',
        phone: profile['phone'] as String? ?? '',
        address: profile['address'] as String? ?? '',
        gender: _parseGender(profile['gender'] as String?),
        dateOfBirth: dob,
        profileImageUrl: profile['profile_image_url'] as String? ?? '',
      );
      
      _lastSaved = newState;
      emit(newState);
    } catch (e) {
      debugPrint('FamilyProfileCubit.loadProfile error: $e');
      emit(state.copyWith(
        status: FamilyProfileStatus.failure,
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
        'gender': state.gender?.name ?? 'male',
      });
      _lastSaved = state.copyWith(isEditing: false, isSaving: false);
      emit(_lastSaved);
    } catch (e) {
      debugPrint('FamilyProfileCubit.saveChanges error: $e');
      emit(state.copyWith(isSaving: false));
    }
  }

  void nameChanged(String value) => emit(state.copyWith(name: value));
  void phoneChanged(String value) => emit(state.copyWith(phone: value));
  void addressChanged(String value) => emit(state.copyWith(address: value));
  void genderChanged(Gender? value) => emit(state.copyWith(gender: value));
  void dateOfBirthChanged(DateTime value) => emit(state.copyWith(dateOfBirth: value));
  void profileImagePicked(Uint8List bytes) => emit(state.copyWith(profileImageBytes: bytes));

  void logOut() {
    // TODO: clear auth session/tokens once real auth exists.
  }
}
