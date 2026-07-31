part of 'caregiver_profile_cubit.dart';

class CaregiverProfileState extends Equatable {
  const CaregiverProfileState({
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
    this.dailyRate = '',
    this.experienceYears = '',
    this.profileImageBytes,
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

  final String name;
  final String email;

  final String phone;
  final String address;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String specializations;
  final AvailabilityType? availabilityType;
  final String dailyRate;
  final String experienceYears;
  final Uint8List? profileImageBytes;

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
    String? phone,
    String? address,
    Gender? gender,
    DateTime? dateOfBirth,
    String? specializations,
    AvailabilityType? availabilityType,
    String? dailyRate,
    String? experienceYears,
    Uint8List? profileImageBytes,
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
      name: name,
      email: email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      specializations: specializations ?? this.specializations,
      availabilityType: availabilityType ?? this.availabilityType,
      dailyRate: dailyRate ?? this.dailyRate,
      experienceYears: experienceYears ?? this.experienceYears,
      profileImageBytes: profileImageBytes ?? this.profileImageBytes,
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
    name,
    email,
    phone,
    address,
    gender,
    dateOfBirth,
    specializations,
    availabilityType,
    dailyRate,
    experienceYears,
    profileImageBytes,
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