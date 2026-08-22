import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/caregiver_signup/caregiver_signup.dart';
import 'package:frontend/core/enums/gender.dart';

import '../data/caregiver_profile_dummy_data.dart';

part 'caregiver_profile_state.dart';

class CaregiverProfileCubit extends Cubit<CaregiverProfileState> {
  CaregiverProfileCubit()
      : super(
    CaregiverProfileState(
      name: CaregiverProfileDummyData.name,
      email: CaregiverProfileDummyData.email,
      phone: CaregiverProfileDummyData.phone,
      address: CaregiverProfileDummyData.address,
      gender: CaregiverProfileDummyData.gender,
      dateOfBirth: CaregiverProfileDummyData.dateOfBirth,
      specializations: CaregiverProfileDummyData.specializations,
      availabilityType: CaregiverProfileDummyData.availabilityType,
      hourlyRate: CaregiverProfileDummyData.hourlyRate,
      experienceYears: CaregiverProfileDummyData.experienceYears,
      documents: CaregiverProfileDummyData.documents,
      totalEarningsThisMonth: CaregiverProfileDummyData.totalEarningsThisMonth,
      lastPayoutAmount: CaregiverProfileDummyData.lastPayoutAmount,
      lastPayoutDate: CaregiverProfileDummyData.lastPayoutDate,
      earningsSparkline: CaregiverProfileDummyData.earningsSparkline,
    ),
  ) {
    _lastSaved = state;
  }

  /// Snapshot to revert to if the user cancels an edit session.
  late CaregiverProfileState _lastSaved;

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
