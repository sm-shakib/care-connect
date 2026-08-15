import 'dart:typed_data';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/core/utils/validators.dart';

part 'elderly_signup_state.dart';

class ElderlySignupCubit extends Cubit<ElderlySignupState> {
  ElderlySignupCubit() : super(const ElderlySignupState());

  final _authRepository = AuthRepository();

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
  void healthConditionChanged(String value) =>
      emit(state.copyWith(healthCondition: value));

  void togglePasswordVisibility() =>
      emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  void toggleConfirmPasswordVisibility() => emit(
    state.copyWith(
      isConfirmPasswordObscured: !state.isConfirmPasswordObscured,
    ),
  );

  void profileImagePicked(Uint8List bytes) =>
      emit(state.copyWith(profileImageBytes: bytes));

  /// Validates the current step; advances to the next step only if valid.
  void nextStep() {
    emit(state.copyWith(submitAttempted: true));

    final canAdvance =
    state.currentStep == 0 ? state.isStep1Valid : state.isStep2Valid;
    if (!canAdvance) return;

    if (state.isLastStep) {
      submit();
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
      state.copyWith(currentStep: state.currentStep - 1, submitAttempted: false),
    );
  }

  /// Called once both steps are valid.
  /// Hook your real "register elderly person" API call up here.
  Future<void> submit() async {
    emit(state.copyWith(status: ElderlySignupStatus.submitting));
    try {
      String? profileImageUrl;

      // 1. Upload image to Cloudinary if available
      if (state.profileImageBytes != null) {
        profileImageUrl = await _authRepository.uploadFile(
          state.profileImageBytes!,
          'profile_picture.jpg',
        );
      }

      // 2. Prepare registration data
      final signupData = {
        'user': {
          'email': state.email,
          'password': state.password,
          'role': 'elder',
          'is_active': true,
        },
        'profile': {
          'name': state.name,
          'gender': state.gender?.name ?? 'Other',
          'date_of_birth': state.dateOfBirth?.toIso8601String().split('T')[0],
          'phone': state.phone,
          'address': state.address,
          'health_condition': state.healthCondition,
          'profile_image_url': profileImageUrl,
        },
      };

      await _authRepository.signupElder(signupData);
      emit(state.copyWith(status: ElderlySignupStatus.success));
    } catch (e) {
      print("SIGNUP ERROR DETAILS: $e");
      emit(state.copyWith(status: ElderlySignupStatus.failure));
    }
  }
}