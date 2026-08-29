part of 'caregiver_signup_cubit.dart';

enum CaregiverSignupStatus { initial, submitting, success, failure }

/// Availability options mapped to `Caregiver_Profiles.availability_type`.
enum AvailabilityType { fullTime, partTime, onCall, weekendsOnly }

extension AvailabilityTypeLabel on AvailabilityType {
  String label(BuildContext context) {
    switch (this) {
      case AvailabilityType.fullTime:
        return context.l10n.availabilityFullTime;
      case AvailabilityType.partTime:
        return context.l10n.availabilityPartTime;
      case AvailabilityType.onCall:
        return context.l10n.availabilityOnCall;
      case AvailabilityType.weekendsOnly:
        return context.l10n.availabilityWeekendsOnly;
    }
  }
}



/// Required documents mapped to rows in `Caregiver_Documents`
/// (one row per uploaded document: document_type + document_url).
enum CaregiverDocumentType { nationalId, certificate, policeClearance }

extension CaregiverDocumentTypeLabel on CaregiverDocumentType {
  String label(BuildContext context) {
    switch (this) {
      case CaregiverDocumentType.nationalId:
        return context.l10n.documentNationalId;
      case CaregiverDocumentType.certificate:
        return context.l10n.documentCertificate;
      case CaregiverDocumentType.policeClearance:
        return context.l10n.documentPoliceClearance;
    }
  }
}

class CaregiverSignupState extends Equatable {
  const CaregiverSignupState({
    this.currentStep = 0,
    // Step 1 — Basic Info
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
    // Step 2 — Professional Info (Caregiver_Profiles)
    this.specializations = '',
    this.availabilityType,
    this.hourlyRate = '',
    this.experienceYears = '',
    // Step 3 — Documents (Caregiver_Documents)
    this.uploadedDocuments = const {},
    this.status = CaregiverSignupStatus.initial,
    this.submitAttempted = false,
  });

  static const int stepCount = 3;

  final int currentStep;

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

  final String specializations;
  final AvailabilityType? availabilityType;
  final String hourlyRate;
  final String experienceYears;

  final Map<CaregiverDocumentType, PlatformFile> uploadedDocuments;

  final CaregiverSignupStatus status;
  final bool submitAttempted;

  bool get isSubmitting => status == CaregiverSignupStatus.submitting;
  bool get isSuccess => status == CaregiverSignupStatus.success;
  bool get isLastStep => currentStep == stepCount - 1;

  // ---- Step 1 errors ----
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

  // ---- Step 2 errors ----
  String? get specializationsError => submitAttempted
      ? validateRequired(specializations, fieldName: 'Specializations')
      : null;
  String? get availabilityTypeError =>
      submitAttempted && availabilityType == null
          ? 'Please select your availability.'
          : null;
  String? get hourlyRateError =>
      submitAttempted ? validateHourlyRate(hourlyRate) : null;
  String? get experienceYearsError =>
      submitAttempted ? validateExperienceYears(experienceYears) : null;

  bool get isStep2Valid =>
      validateRequired(specializations, fieldName: 'Specializations') ==
          null &&
          availabilityType != null &&
          validateHourlyRate(hourlyRate) == null &&
          validateExperienceYears(experienceYears) == null;

  // ---- Step 3 errors ----
  bool get isStep3Valid => CaregiverDocumentType.values
      .every(uploadedDocuments.containsKey);

  CaregiverSignupState copyWith({
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
    String? specializations,
    AvailabilityType? availabilityType,
    String? hourlyRate,
    String? experienceYears,
    Map<CaregiverDocumentType, PlatformFile>? uploadedDocuments,
    CaregiverSignupStatus? status,
    bool? submitAttempted,
  }) {
    return CaregiverSignupState(
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
      specializations: specializations ?? this.specializations,
      availabilityType: availabilityType ?? this.availabilityType,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      experienceYears: experienceYears ?? this.experienceYears,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
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
    specializations,
    availabilityType,
    hourlyRate,
    experienceYears,
    uploadedDocuments,
    status,
    submitAttempted,
  ];
}
