import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/utils/validators.dart';

part 'family_signup_state.dart';

class FamilySignupCubit extends Cubit<FamilySignupState> {
  FamilySignupCubit() : super(const FamilySignupState());

  void nameChanged(String value) => emit(state.copyWith(name: value));
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
      // TODO: replace with a real API call, e.g.
      // await authRepository.registerFamilyMember(
      //   name: state.name,
      //   phone: state.phone,
      //   email: state.email,
      //   address: state.address,
      //   password: state.password,
      //   profileImage: state.profileImageBytes,
      // );
      await Future.delayed(const Duration(milliseconds: 900));
      emit(state.copyWith(status: FamilySignupStatus.success));
    } catch (_) {
      emit(state.copyWith(status: FamilySignupStatus.failure));
    }
  }
}