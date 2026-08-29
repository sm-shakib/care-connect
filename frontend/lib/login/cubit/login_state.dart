part of 'login_cubit.dart';

enum LoginStatus { initial, submitting, success, failure }

class LoginState extends Equatable {
  final String emailOrPhone;
  final String password;
  final bool isPasswordObscured;
  final LoginStatus status;
  final String? role;
  final String? accountStatus;
  final String? errorMessage;

  const LoginState({
    this.emailOrPhone = '',
    this.password = '',
    this.isPasswordObscured = true,
    this.status = LoginStatus.initial,
    this.role,
    this.accountStatus,
    this.errorMessage,
  });

  bool get isValid => emailOrPhone.trim().isNotEmpty && password.trim().isNotEmpty;
  bool get isSubmitting => status == LoginStatus.submitting;
  bool get isSuccess => status == LoginStatus.success;
  bool get isFailure => status == LoginStatus.failure;

  LoginState copyWith({
    String? emailOrPhone,
    String? password,
    bool? isPasswordObscured,
    LoginStatus? status,
    String? role,
    String? accountStatus,
    String? errorMessage,
  }) {
    return LoginState(
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      password: password ?? this.password,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      status: status ?? this.status,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    emailOrPhone,
    password,
    isPasswordObscured,
    status,
    role,
    accountStatus,
    errorMessage,
  ];
}
