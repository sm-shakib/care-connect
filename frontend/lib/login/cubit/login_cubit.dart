import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void emailOrPhoneChanged(String value) {
    emit(state.copyWith(emailOrPhone: value));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

  /// Called when the user taps "Login".
  /// Hook your real authentication call up here.
  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(isSubmitting: true));

    // TODO: replace with real authentication logic.
    await Future.delayed(const Duration(milliseconds: 800));

    emit(state.copyWith(isSubmitting: false));
  }
}