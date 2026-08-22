import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  final _authRepository = AuthRepository();

  void emailOrPhoneChanged(String value) {
    emit(state.copyWith(emailOrPhone: value, status: LoginStatus.initial, errorMessage: null));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: LoginStatus.initial, errorMessage: null));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

  /// Called when the user taps "Login".
  /// Hook your real authentication call up here.
  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: LoginStatus.submitting));

    try {
      final result = await _authRepository.login(state.emailOrPhone, state.password);
      final role = result['role'] as String?;
      final status = result['status'] as String?;
      emit(state.copyWith(status: LoginStatus.success, role: role, accountStatus: status));
    } on DioException catch (e) {
      String? message;
      if (e.response?.data != null && e.response?.data is Map) {
        message = e.response?.data['detail']?.toString();
      }
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: message ?? 'Incorrect email or password',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'Something went wrong'));
    }
  }
}
