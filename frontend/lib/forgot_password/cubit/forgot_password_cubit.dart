import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(const ForgotPasswordState());

  void emailOrPhoneChanged(String value) {
    emit(state.copyWith(emailOrPhone: value));
  }

  /// Called when the user taps "Send Reset Code".
  /// Hook your real "send reset code/link" API call up here.
  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: ForgotPasswordStatus.submitting));

    try {
      // TODO: replace with a real API call, e.g.
      // await authRepository.requestPasswordReset(state.emailOrPhone);
      await Future.delayed(const Duration(milliseconds: 800));
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } catch (_) {
      emit(state.copyWith(status: ForgotPasswordStatus.failure));
    }
  }
}
