import 'dart:async';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/l10n/l10n.dart';

part 'caregiver_signup_state.dart';

class CaregiverSignupCubit extends Cubit<CaregiverSignupState> {
  CaregiverSignupCubit() : super(const CaregiverSignupState());

  // ---- Step 1 ----
  void nameChanged(String value) => emit(state.copyWith(name: value));
  void genderChanged(Gender? value) => emit(state.copyWith(gender: value));
  void dateOfBirthChanged(DateTime value) =>
      emit(state.copyWith(dateOfBirth: value));
  void phoneChanged(String value) => emit(state.copyWith(phone: value));
  void emailChanged(String value) => emit(state.copyWith(email: value));
  void addressChanged(String value) => emit(state.copyWith(address: value));
  void passwordChanged(String value) =>
      emit(state.copyWith(password: value));
  void confirmPasswordChanged(String value) =>
      emit(state.copyWith(confirmPassword: value));

  void togglePasswordVisibility() =>
      emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  void toggleConfirmPasswordVisibility() => emit(
    state.copyWith(
      isConfirmPasswordObscured: !state.isConfirmPasswordObscured,
    ),
  );

  void profileImagePicked(Uint8List bytes) =>
      emit(state.copyWith(profileImageBytes: bytes));

  // ---- Step 2 ----
  void specializationsChanged(String value) =>
      emit(state.copyWith(specializations: value));
  void availabilityTypeChanged(AvailabilityType? value) =>
      emit(state.copyWith(availabilityType: value));
  void experienceYearsChanged(String value) =>
      emit(state.copyWith(experienceYears: value));
  void dailyRateChanged(String value) =>
      emit(state.copyWith(dailyRate: value));

  // ---- Step 3 ----
  void documentPicked(CaregiverDocumentType type, PlatformFile file) {
    final updated = Map<CaregiverDocumentType, PlatformFile>.from(
      state.uploadedDocuments,
    )..[type] = file;
    emit(state.copyWith(uploadedDocuments: updated));
  }

  /// Validates the current step; advances to the next step only if valid.
  void nextStep() {
    emit(state.copyWith(submitAttempted: true));

    final canAdvance = switch (state.currentStep) {
      0 => state.isStep1Valid,
      1 => state.isStep2Valid,
      _ => state.isStep3Valid,
    };
    if (!canAdvance) return;

    if (state.isLastStep) {
      unawaited(submit());
    } else {
      emit(
        state.copyWith(
          currentStep: state.currentStep + 1,
          submitAttempted: false,
        ),
      );
    }
  }

  void previousStep() {
    if (state.currentStep == 0) return;
    emit(
      state.copyWith(
        currentStep: state.currentStep - 1,
        submitAttempted: false,
      ),
    );
  }

  /// Called once all three steps are valid.
  /// Hook your real "register caregiver" + document upload API calls here.
  /// Note: is_verified stays false until an admin reviews the documents.
  Future<void> submit() async {
    emit(state.copyWith(status: CaregiverSignupStatus.submitting));
    try {
      // TODO: replace with real API calls, e.g.
      // final userId = await authRepository.registerCaregiver(
      //   name: state.name,
      //   phone: state.phone,
      //   email: state.email,
      //   address: state.address,
      //   password: state.password,
      //   profileImage: state.profileImageBytes,
      //   specializations: state.specializations,
      //   availabilityType: state.availabilityType!.label,
      //   dailyRate: double.parse(state.dailyRate),
      // );
      // for (final entry in state.uploadedDocuments.entries) {
      //   await documentRepository.uploadCaregiverDocument(
      //     caregiverId: userId,
      //     documentType: entry.key.label,
      //     file: entry.value,
      //   );
      // }
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      emit(state.copyWith(status: CaregiverSignupStatus.success));
    } on Exception catch (_) {
      emit(state.copyWith(status: CaregiverSignupStatus.failure));
    }
  }
}
