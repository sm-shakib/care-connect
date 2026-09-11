import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/repositories/auth_repository.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit({required String email, required String otp}) 
      : super(ResetPasswordState(email: email, otp: otp));

  final _authRepository = AuthRepository();

  void newPasswordChanged(String value) {
    emit(state.copyWith(newPassword: value));
  }

  void confirmPasswordChanged(String value) {
    emit(state.copyWith(confirmPassword: value));
  }

  void toggleNewPasswordVisibility() {
    emit(state.copyWith(isNewPasswordObscured: !state.isNewPasswordObscured));
  }

  void toggleConfirmPasswordVisibility() {
    emit(
      state.copyWith(
        isConfirmPasswordObscured: !state.isConfirmPasswordObscured,
      ),
    );
  }

  /// Called when the user taps "Reset Password".
  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: ResetPasswordStatus.submitting));

    try {
      await _authRepository.resetPassword(
        email: state.email,
        otp: state.otp,
        newPassword: state.newPassword,
      );
      emit(state.copyWith(status: ResetPasswordStatus.success));
    } catch (e) {
      print('Reset Password Error: $e');
      emit(state.copyWith(status: ResetPasswordStatus.failure));
    }
  }
}
