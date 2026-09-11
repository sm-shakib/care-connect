import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/repositories/auth_repository.dart';

part 'otp_verification_state.dart';

class OtpVerificationCubit extends Cubit<OtpVerificationState> {
  OtpVerificationCubit({required String email}) 
      : super(OtpVerificationState(email: email)) {
    _startResendTimer();
  }

  final _authRepository = AuthRepository();
  Timer? _resendTimer;

  void codeChanged(String value) {
    final status = state.status == OtpVerificationStatus.failure
        ? OtpVerificationStatus.initial
        : state.status;
    emit(state.copyWith(code: value, status: status));
  }

  /// Called when the user taps "Verify".
  Future<void> verify() async {
    if (!state.isComplete) return;
    emit(state.copyWith(status: OtpVerificationStatus.verifying));

    try {
      await _authRepository.verifyOtp(state.email, state.code);
      emit(state.copyWith(status: OtpVerificationStatus.success));
    } catch (e) {
      print('OTP Verification Error: $e');
      emit(state.copyWith(status: OtpVerificationStatus.failure));
    }
  }

  /// Called when the user taps "Resend Code".
  Future<void> resendCode() async {
    if (!state.canResend) return;

    try {
      await _authRepository.requestPasswordReset(state.email);
      emit(
        state.copyWith(
          code: '',
          resendSecondsRemaining: OtpVerificationState.resendCooldownSeconds,
        ),
      );
      _startResendTimer();
    } catch (e) {
      print('Resend OTP Error: $e');
      emit(state.copyWith(status: OtpVerificationStatus.failure));
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendSecondsRemaining <= 1) {
        timer.cancel();
        emit(state.copyWith(resendSecondsRemaining: 0));
      } else {
        emit(
          state.copyWith(
            resendSecondsRemaining: state.resendSecondsRemaining - 1,
          ),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }
}
