import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/core/utils/validators.dart';

part 'family_signup_state.dart';

class FamilySignupCubit extends Cubit<FamilySignupState> {
  FamilySignupCubit() : super(const FamilySignupState());

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

  void togglePasswordVisibility() =>
      emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  void toggleConfirmPasswordVisibility() => emit(
    state.copyWith(
      isConfirmPasswordObscured: !state.isConfirmPasswordObscured,
    ),
  );

  void profileImagePicked(Uint8List bytes) =>
      emit(state.copyWith(profileImageBytes: bytes));

  /// Called when the user taps "Create Account".
  /// Hook your real "register family member" API call up here.
  Future<void> submit() async {
    emit(state.copyWith(submitAttempted: true));
    if (!state.isValid) return;

    emit(state.copyWith(status: FamilySignupStatus.submitting));
    try {
      String? profileImageUrl;

      // 1. Upload profile image to Cloudinary
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
          'role': 'family',
          'is_active': true,
        },
        'profile': {
          'name': state.name,
          'gender': state.gender?.name ?? 'Other',
          'date_of_birth': state.dateOfBirth?.toIso8601String().split('T')[0],
          'phone': state.phone,
          'address': state.address,
          'profile_image_url': profileImageUrl,
        },
      };

      await _authRepository.signupFamily(signupData);

      // Auto-login after successful signup to set tokens and profile ID
      await _authRepository.login(state.email, state.password);

      emit(state.copyWith(status: FamilySignupStatus.success));
    } on DioException catch (_) {
      emit(state.copyWith(status: FamilySignupStatus.failure));
    } catch (_) {
      emit(state.copyWith(status: FamilySignupStatus.failure));
    }
  }
}
