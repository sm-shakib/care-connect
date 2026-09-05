part of 'caregiver_profile_cubit.dart';

enum CaregiverProfileStatus { initial, loading, success, failure }

class CaregiverProfileState extends Equatable {
  const CaregiverProfileState({
    this.status = CaregiverProfileStatus.initial,
    this.errorMessage,
    // Not editable — shown read-only regardless of edit mode.
    this.name = '',
    this.email = '',
    // Editable personal info (collected at signup).
    this.phone = '',
    this.address = '',
    this.gender,
    this.dateOfBirth,
    this.specializations = '',
    this.availabilityType,
    this.hourlyRate = '',
    this.experienceYears = '',
    this.profileImageBytes,
    this.profileImageUrl = '',
    // Verified documents (view-only here).
    this.documents = const {},
    // Earnings.
    this.totalEarningsThisMonth = 0,
    this.lastPayoutAmount = 0,
    this.lastPayoutDate,
    this.earningsSparkline = const [],
    // Edit-mode bookkeeping.
    this.isEditing = false,
    this.isSaving = false,
    this.editSessionId = 0,
  });

  final CaregiverProfileStatus status;
  final String? errorMessage;

  final String name;
  final String email;

  final String phone;
  final String address;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String specializations;
  final AvailabilityType? availabilityType;
  final String hourlyRate;
  final String experienceYears;
  final Uint8List? profileImageBytes;
  final String profileImageUrl;

  final Map<CaregiverDocumentType, String> documents;

  final double totalEarningsThisMonth;
  final double lastPayoutAmount;
  final DateTime? lastPayoutDate;
  final List<double> earningsSparkline;

  final bool isEditing;
  final bool isSaving;

  /// Bumped whenever edit mode starts or is cancelled, so editable text
  /// fields (keyed on this) remount and pick up fresh values instead of
  /// keeping stale user-typed text from a previous edit session.
  final int editSessionId;

  CaregiverProfileState copyWith({
    CaregiverProfileStatus? status,
    String? errorMessage,
    String? name,
    String? email,
    String? phone,
    String? address,
    Gender? gender,
    DateTime? dateOfBirth,
    String? specializations,
    AvailabilityType? availabilityType,
    String? hourlyRate,
    String? experienceYears,
    Uint8List? profileImageBytes,
    String? profileImageUrl,
    Map<CaregiverDocumentType, String>? documents,
    double? totalEarningsThisMonth,
    double? lastPayoutAmount,
    DateTime? lastPayoutDate,
    List<double>? earningsSparkline,
    bool? isEditing,
    bool? isSaving,
    int? editSessionId,
  }) {
    return CaregiverProfileState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      specializations: specializations ?? this.specializations,
      availabilityType: availabilityType ?? this.availabilityType,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      experienceYears: experienceYears ?? this.experienceYears,
      profileImageBytes: profileImageBytes ?? this.profileImageBytes,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      documents: documents ?? this.documents,
      totalEarningsThisMonth: totalEarningsThisMonth ?? this.totalEarningsThisMonth,
      lastPayoutAmount: lastPayoutAmount ?? this.lastPayoutAmount,
      lastPayoutDate: lastPayoutDate ?? this.lastPayoutDate,
      earningsSparkline: earningsSparkline ?? this.earningsSparkline,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      editSessionId: editSessionId ?? this.editSessionId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    name,
    email,
    phone,
    address,
    gender,
    dateOfBirth,
    specializations,
    availabilityType,
    hourlyRate,
    experienceYears,
    profileImageBytes,
    profileImageUrl,
    documents,
    totalEarningsThisMonth,
    lastPayoutAmount,
    lastPayoutDate,
    earningsSparkline,
    isEditing,
    isSaving,
    editSessionId,
  ];
}
