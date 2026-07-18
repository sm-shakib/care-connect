part of 'otp_verification_cubit.dart';

enum OtpVerificationStatus { initial, verifying, success, failure }

class OtpVerificationState extends Equatable {
  static const int codeLength = 6;
  static const int resendCooldownSeconds = 30;

  final String code;
  final OtpVerificationStatus status;
  final int resendSecondsRemaining;

  const OtpVerificationState({
    this.code = '',
    this.status = OtpVerificationStatus.initial,
    this.resendSecondsRemaining = resendCooldownSeconds,
  });

  bool get isComplete => code.length == codeLength;
  bool get isVerifying => status == OtpVerificationStatus.verifying;
  bool get isSuccess => status == OtpVerificationStatus.success;
  bool get isFailure => status == OtpVerificationStatus.failure;
  bool get canResend => resendSecondsRemaining == 0;

  OtpVerificationState copyWith({
    String? code,
    OtpVerificationStatus? status,
    int? resendSecondsRemaining,
  }) {
    return OtpVerificationState(
      code: code ?? this.code,
      status: status ?? this.status,
      resendSecondsRemaining:
          resendSecondsRemaining ?? this.resendSecondsRemaining,
    );
  }

  @override
  List<Object?> get props => [code, status, resendSecondsRemaining];
}
