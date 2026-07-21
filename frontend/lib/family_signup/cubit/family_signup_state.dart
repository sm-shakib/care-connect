part of 'family_signup_cubit.dart';

enum FamilySignupStatus { initial, submitting, success, failure }

class FamilySignupState extends Equatable {
  const FamilySignupState({
    this.name = '',
    this.gender,
    this.dateOfBirth,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.password = '',
    this.confirmPassword = '',
    this.isPasswordObscured = true,
    this.isConfirmPasswordObscured = true,
    this.profileImageBytes,
    this.status = FamilySignupStatus.initial,
    this.submitAttempted = false,
  });

  final String name;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String phone;
  final String email;
  final String address;
  final String password;
  final String confirmPassword;
  final bool isPasswordObscured;
  final bool isConfirmPasswordObscured;
  final Uint8List? profileImageBytes;
  final FamilySignupStatus status;

  /// True once the user has tapped "Create Account" at least once —
  /// used to withhold field errors until the first submit attempt.
  final bool submitAttempted;

  bool get isSubmitting => status == FamilySignupStatus.submitting;
  bool get isSuccess => status == FamilySignupStatus.success;

  String? get nameError => submitAttempted ? validateName(name) : null;
  String? get genderError => submitAttempted && gender == null
      ? 'Please select your gender.'
      : null;
  String? get dateOfBirthError =>
      submitAttempted ? validateDateOfBirth(dateOfBirth) : null;
  String? get phoneError => submitAttempted ? validatePhone(phone) : null;
  String? get emailError => submitAttempted ? validateEmail(email) : null;
  String? get addressError =>
      submitAttempted ? validateAddress(address) : null;
  String? get passwordError =>
      submitAttempted ? validatePassword(password) : null;
  String? get confirmPasswordError => submitAttempted
      ? validateConfirmPassword(password, confirmPassword)
      : null;
  String? get imageError =>
      submitAttempted && profileImageBytes == null
          ? 'Please add a profile picture.'
          : null;

  bool get isValid =>
      validateName(name) == null &&
          gender != null &&
          validateDateOfBirth(dateOfBirth) == null &&
          validatePhone(phone) == null &&
          validateEmail(email) == null &&
          validateAddress(address) == null &&
          validatePassword(password) == null &&
          validateConfirmPassword(password, confirmPassword) == null &&
          profileImageBytes != null;

  FamilySignupState copyWith({
    String? name,
    Gender? gender,
    DateTime? dateOfBirth,
    String? phone,
    String? email,
    String? address,
    String? password,
    String? confirmPassword,
    bool? isPasswordObscured,
    bool? isConfirmPasswordObscured,
    Uint8List? profileImageBytes,
    FamilySignupStatus? status,
    bool? submitAttempted,
  }) {
    return FamilySignupState(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isConfirmPasswordObscured:
      isConfirmPasswordObscured ?? this.isConfirmPasswordObscured,
      profileImageBytes: profileImageBytes ?? this.profileImageBytes,
      status: status ?? this.status,
      submitAttempted: submitAttempted ?? this.submitAttempted,
    );
  }

  @override
  List<Object?> get props => [
    name,
    gender,
    dateOfBirth,
    phone,
    email,
    address,
    password,
    confirmPassword,
    isPasswordObscured,
    isConfirmPasswordObscured,
    profileImageBytes,
    status,
    submitAttempted,
  ];
}