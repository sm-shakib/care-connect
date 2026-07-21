part of 'elderly_signup_cubit.dart';

enum ElderlySignupStatus { initial, submitting, success, failure }

class ElderlySignupState extends Equatable {
  const ElderlySignupState({
    this.currentStep = 0,
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
    this.healthCondition = '',
    this.status = ElderlySignupStatus.initial,
    this.submitAttempted = false,
  });

  static const int stepCount = 2;

  final int currentStep;

  // Step 1 — Basic Info (Users table)
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

  // Step 2 — Health Info (Elderly_Profiles.health_condition)
  final String healthCondition;

  final ElderlySignupStatus status;

  /// True once the user has attempted to advance/submit the *current*
  /// step at least once — resets per step via [copyWith] calls in the
  /// cubit's nextStep().
  final bool submitAttempted;

  bool get isSubmitting => status == ElderlySignupStatus.submitting;
  bool get isSuccess => status == ElderlySignupStatus.success;
  bool get isLastStep => currentStep == stepCount - 1;

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
  String? get imageError => submitAttempted && profileImageBytes == null
      ? 'Please add a profile picture.'
      : null;
  String? get healthConditionError =>
      submitAttempted ? validateRequired(healthCondition, fieldName: 'Health condition') : null;

  bool get isStep1Valid =>
      validateName(name) == null &&
          gender != null &&
          validateDateOfBirth(dateOfBirth) == null &&
          validatePhone(phone) == null &&
          validateEmail(email) == null &&
          validateAddress(address) == null &&
          validatePassword(password) == null &&
          validateConfirmPassword(password, confirmPassword) == null &&
          profileImageBytes != null;

  bool get isStep2Valid =>
      validateRequired(healthCondition, fieldName: 'Health condition') ==
          null;

  ElderlySignupState copyWith({
    int? currentStep,
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
    String? healthCondition,
    ElderlySignupStatus? status,
    bool? submitAttempted,
  }) {
    return ElderlySignupState(
      currentStep: currentStep ?? this.currentStep,
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
      healthCondition: healthCondition ?? this.healthCondition,
      status: status ?? this.status,
      submitAttempted: submitAttempted ?? this.submitAttempted,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
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
    healthCondition,
    status,
    submitAttempted,
  ];
}