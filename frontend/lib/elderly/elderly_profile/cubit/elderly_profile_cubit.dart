import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/enums/gender.dart';
import '../data/elderly_profile_dummy_data.dart';

part 'elderly_profile_state.dart';

class ElderlyProfileCubit extends Cubit<ElderlyProfileState> {
  ElderlyProfileCubit()
      : super(
          ElderlyProfileState(
            name: ElderlyProfileDummyData.name,
            email: ElderlyProfileDummyData.email,
            phone: ElderlyProfileDummyData.phone,
            address: ElderlyProfileDummyData.address,
            gender: ElderlyProfileDummyData.gender,
            dateOfBirth: ElderlyProfileDummyData.dateOfBirth,
            healthCondition: ElderlyProfileDummyData.healthCondition,
          ),
        ) {
    _lastSaved = state;
  }

  late ElderlyProfileState _lastSaved;

  void startEditing() {
    _lastSaved = state;
    emit(state.copyWith(isEditing: true, editSessionId: state.editSessionId + 1));
  }

  void cancelEditing() {
    emit(_lastSaved.copyWith(isEditing: false, editSessionId: state.editSessionId + 1));
  }

  Future<void> saveChanges() async {
    emit(state.copyWith(isSaving: true));
    // TODO: send the updated fields to a real profile-update API.
    await Future.delayed(const Duration(milliseconds: 600));
    _lastSaved = state.copyWith(isEditing: false, isSaving: false);
    emit(_lastSaved);
  }

  void nameChanged(String value) => emit(state.copyWith(name: value));
  void phoneChanged(String value) => emit(state.copyWith(phone: value));
  void addressChanged(String value) => emit(state.copyWith(address: value));
  void genderChanged(Gender? value) => emit(state.copyWith(gender: value));
  void dateOfBirthChanged(DateTime value) => emit(state.copyWith(dateOfBirth: value));
  void healthConditionChanged(String value) => emit(state.copyWith(healthCondition: value));
  void profileImagePicked(Uint8List bytes) => emit(state.copyWith(profileImageBytes: bytes));

  void logOut() {
    // Handled in view
  }
}
