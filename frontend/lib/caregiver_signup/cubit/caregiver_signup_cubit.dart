import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/l10n/l10n.dart';

part 'caregiver_signup_state.dart';

class CaregiverSignupCubit extends Cubit<CaregiverSignupState> {
  CaregiverSignupCubit() : super(const CaregiverSignupState());

  final _authRepository = AuthRepository();

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
  void hourlyRateChanged(String value) =>
      emit(state.copyWith(hourlyRate: value));

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
      String? profileImageUrl;

      // 1. Upload profile image to Cloudinary
      if (state.profileImageBytes != null) {
        profileImageUrl = await _authRepository.uploadFile(
          state.profileImageBytes!,
          'profile_picture.jpg',
        );
      }

      // 2. Upload documents to Cloudinary
      final documents = <Map<String, String>>[];
      for (final entry in state.uploadedDocuments.entries) {
        if (entry.value.bytes != null) {
          final docUrl = await _authRepository.uploadFile(
            entry.value.bytes!,
            entry.value.name, // Use actual filename from PlatformFile
          );
          if (docUrl != null) {
            documents.add({
              'document_type': entry.key.name,
              'document_url': docUrl,
            });
          }
        }
      }

      // 3. Prepare registration data
      final signupData = {
        'user': {
          'email': state.email,
          'password': state.password,
          'role': 'caregiver',
          'is_active': true,
        },
        'profile': {
          'name': state.name,
          'gender': state.gender?.name ?? 'Other',
          'date_of_birth': state.dateOfBirth?.toIso8601String().split('T')[0],
          'phone': state.phone,
          'address': state.address,
          'profile_image_url': profileImageUrl,
          'specializations': state.specializations,
          'availability_type': state.availabilityType?.name ?? 'fullTime',
          'hourly_rate': double.tryParse(state.hourlyRate) ?? 0.0,
          'experience_years': int.tryParse(state.experienceYears) ?? 0,
        },
        'documents': documents,
      };

      await _authRepository.signupCaregiver(signupData);

      // Auto-login after successful signup to set tokens and profile ID
      await _authRepository.login(state.email, state.password);

      emit(state.copyWith(status: CaregiverSignupStatus.success));
    } on DioException catch (e) {
      // You could add an error message field to state similar to ElderSignup
      emit(state.copyWith(status: CaregiverSignupStatus.failure));
    } catch (e) {
      emit(state.copyWith(status: CaregiverSignupStatus.failure));
    }
  }
}
