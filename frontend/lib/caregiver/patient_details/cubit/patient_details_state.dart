part of 'patient_details_cubit.dart';

class PatientDetailsState extends Equatable {
  const PatientDetailsState({
    required this.patientId,
    required this.patientName,
    this.bpSystolic = 120,
    this.bpDiastolic = 80,
    this.bpCheckedAt,
    this.bpStatusLabel = 'STABLE',
    this.heartRateBpm = 72,
    this.heartRateCheckedAt,
    this.heartRateRecent = const [40, 60, 80, 50, 70],
    this.medications = const [],
    this.otherReminders = const [],
    this.appointments = const [],
    this.gender,
    this.dateOfBirth,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.healthCondition = '',
  });

  final String patientId;
  final String patientName;

  final int bpSystolic;
  final int bpDiastolic;
  final DateTime? bpCheckedAt;
  final String bpStatusLabel;

  final int heartRateBpm;
  final DateTime? heartRateCheckedAt;
  final List<int> heartRateRecent;

  final List<Medicine> medications;
  final List<CareReminder> otherReminders;
  final List<Appointment> appointments;

  // Basic info collected during the elderly's signup.
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String phone;
  final String email;
  final String address;
  final String healthCondition;

  int get medicationsRemainingCount =>
      medications.where((m) => !m.isTakenToday).length;

  PatientDetailsState copyWith({
    int? bpSystolic,
    int? bpDiastolic,
    DateTime? bpCheckedAt,
    String? bpStatusLabel,
    int? heartRateBpm,
    DateTime? heartRateCheckedAt,
    List<int>? heartRateRecent,
    List<Medicine>? medications,
    List<CareReminder>? otherReminders,
    List<Appointment>? appointments,
    Gender? gender,
    DateTime? dateOfBirth,
    String? phone,
    String? email,
    String? address,
    String? healthCondition,
  }) {
    return PatientDetailsState(
      patientId: patientId,
      patientName: patientName,
      bpSystolic: bpSystolic ?? this.bpSystolic,
      bpDiastolic: bpDiastolic ?? this.bpDiastolic,
      bpCheckedAt: bpCheckedAt ?? this.bpCheckedAt,
      bpStatusLabel: bpStatusLabel ?? this.bpStatusLabel,
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      heartRateCheckedAt: heartRateCheckedAt ?? this.heartRateCheckedAt,
      heartRateRecent: heartRateRecent ?? this.heartRateRecent,
      medications: medications ?? this.medications,
      otherReminders: otherReminders ?? this.otherReminders,
      appointments: appointments ?? this.appointments,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      healthCondition: healthCondition ?? this.healthCondition,
    );
  }

  @override
  List<Object?> get props => [
    patientId,
    patientName,
    bpSystolic,
    bpDiastolic,
    bpCheckedAt,
    bpStatusLabel,
    heartRateBpm,
    heartRateCheckedAt,
    heartRateRecent,
    medications,
    otherReminders,
    appointments,
    gender,
    dateOfBirth,
    phone,
    email,
    address,
    healthCondition,
  ];
}
