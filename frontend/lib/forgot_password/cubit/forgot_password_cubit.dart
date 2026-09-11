import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/repositories/auth_repository.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(const ForgotPasswordState());

  final _authRepository = AuthRepository();

  void emailOrPhoneChanged(String value) {
    emit(state.copyWith(emailOrPhone: value));
  }

  /// Called when the user taps "Send Reset Code".
  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: ForgotPasswordStatus.submitting));

    try {
      await _authRepository.requestPasswordReset(state.emailOrPhone);
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } catch (e) {
      print('Forgot Password Error: $e');
      emit(state.copyWith(status: ForgotPasswordStatus.failure));
    }
  }
}
