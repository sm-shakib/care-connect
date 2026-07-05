part of 'login_cubit.dart';

class LoginState extends Equatable {
  final String emailOrPhone;
  final String password;
  final bool isPasswordObscured;
  final bool isSubmitting;

  const LoginState({
    this.emailOrPhone = '',
    this.password = '',
    this.isPasswordObscured = true,
    this.isSubmitting = false,
  });

  bool get isValid => emailOrPhone.trim().isNotEmpty && password.trim().isNotEmpty;

  LoginState copyWith({
    String? emailOrPhone,
    String? password,
    bool? isPasswordObscured,
    bool? isSubmitting,
  }) {
    return LoginState(
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      password: password ?? this.password,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    emailOrPhone,
    password,
    isPasswordObscured,
    isSubmitting,
  ];
}