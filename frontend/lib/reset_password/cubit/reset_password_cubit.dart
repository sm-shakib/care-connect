import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit() : super(const ResetPasswordState());

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
  /// Hook your real "confirm new password" API call up here
  /// (typically alongside a reset token received via email/SMS).
  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: ResetPasswordStatus.submitting));

    try {
      // TODO: replace with a real API call, e.g.
      // await authRepository.resetPassword(token: token, newPassword: state.newPassword);
      await Future.delayed(const Duration(milliseconds: 800));
      emit(state.copyWith(status: ResetPasswordStatus.success));
    } catch (_) {
      emit(state.copyWith(status: ResetPasswordStatus.failure));
    }
  }
}
