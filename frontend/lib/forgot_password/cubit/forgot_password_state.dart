part of 'forgot_password_cubit.dart';

enum ForgotPasswordStatus { initial, submitting, success, failure }

class ForgotPasswordState extends Equatable {
  final String emailOrPhone;
  final ForgotPasswordStatus status;

  const ForgotPasswordState({
    this.emailOrPhone = '',
    this.status = ForgotPasswordStatus.initial,
  });

  static final RegExp _emailRegex = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$',
  );
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

  bool get _looksLikeEmail => emailOrPhone.contains('@');

  /// True once the entered value matches a valid email OR a valid
  /// phone number pattern. Empty input is neither valid nor "shown as
  /// an error" (see [showFormatError]) — we don't nag the user before
  /// they've typed anything.
  bool get isValid {
    final value = emailOrPhone.trim();
    if (value.isEmpty) return false;
    return _looksLikeEmail
        ? _emailRegex.hasMatch(value)
        : _phoneRegex.hasMatch(value);
  }

  /// True when the user has typed something but it doesn't match a
  /// valid email or phone format yet — use this to show inline
  /// field errors without flagging an empty field.
  bool get showFormatError => emailOrPhone.trim().isNotEmpty && !isValid;

  bool get isSubmitting => status == ForgotPasswordStatus.submitting;
  bool get isSuccess => status == ForgotPasswordStatus.success;

  ForgotPasswordState copyWith({
    String? emailOrPhone,
    ForgotPasswordStatus? status,
  }) {
    return ForgotPasswordState(
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [emailOrPhone, status];
}
