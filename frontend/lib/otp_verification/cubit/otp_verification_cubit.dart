import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'otp_verification_state.dart';

class OtpVerificationCubit extends Cubit<OtpVerificationState> {
  OtpVerificationCubit() : super(const OtpVerificationState()) {
    _startResendTimer();
  }

  Timer? _resendTimer;

  void codeChanged(String value) {
    // Clear a previous failure as soon as the user edits the code again.
    final status = state.status == OtpVerificationStatus.failure
        ? OtpVerificationStatus.initial
        : state.status;
    emit(state.copyWith(code: value, status: status));
  }

  /// Called when the user taps "Verify".
  /// Hook your real "verify code" API call up here.
  Future<void> verify() async {
    if (!state.isComplete) return;
    emit(state.copyWith(status: OtpVerificationStatus.verifying));

    try {
      // TODO: replace with a real API call, e.g.
      // final token = await authRepository.verifyCode(emailOrPhone, state.code);
      await Future.delayed(const Duration(milliseconds: 800));
      emit(state.copyWith(status: OtpVerificationStatus.success));
    } catch (_) {
      emit(state.copyWith(status: OtpVerificationStatus.failure));
    }
  }

  /// Called when the user taps "Resend Code".
  Future<void> resendCode() async {
    if (!state.canResend) return;

    // TODO: replace with a real "resend code" API call.
    emit(
      state.copyWith(
        code: '',
        resendSecondsRemaining: OtpVerificationState.resendCooldownSeconds,
      ),
    );
    _startResendTimer();
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
