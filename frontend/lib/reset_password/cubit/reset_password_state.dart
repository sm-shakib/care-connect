part of 'reset_password_cubit.dart';

enum ResetPasswordStatus { initial, submitting, success, failure }

class ResetPasswordState extends Equatable {
  final String newPassword;
  final String confirmPassword;
  final bool isNewPasswordObscured;
  final bool isConfirmPasswordObscured;
  final ResetPasswordStatus status;

  const ResetPasswordState({
    this.newPassword = '',
    this.confirmPassword = '',
    this.isNewPasswordObscured = true,
    this.isConfirmPasswordObscured = true,
    this.status = ResetPasswordStatus.initial,
  });

  static const int minPasswordLength = 8;

  bool get hasMinLength => newPassword.length >= minPasswordLength;
  bool get passwordsMatch =>
      confirmPassword.isNotEmpty && newPassword == confirmPassword;

  bool get isValid => newPassword.isNotEmpty && hasMinLength && passwordsMatch;

  bool get isSubmitting => status == ResetPasswordStatus.submitting;
  bool get isSuccess => status == ResetPasswordStatus.success;

  ResetPasswordState copyWith({
    String? newPassword,
    String? confirmPassword,
    bool? isNewPasswordObscured,
    bool? isConfirmPasswordObscured,
    ResetPasswordStatus? status,
  }) {
    return ResetPasswordState(
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isNewPasswordObscured:
          isNewPasswordObscured ?? this.isNewPasswordObscured,
      isConfirmPasswordObscured:
          isConfirmPasswordObscured ?? this.isConfirmPasswordObscured,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    newPassword,
    confirmPassword,
    isNewPasswordObscured,
    isConfirmPasswordObscured,
    status,
  ];
}
