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

  final List<MedicationReminder> medications;
  final List<CareReminder> otherReminders;

  int get medicationsRemainingCount =>
      medications.where((m) => m.status != MedicationStatus.taken).length;

  PatientDetailsState copyWith({
    int? bpSystolic,
    int? bpDiastolic,
    DateTime? bpCheckedAt,
    String? bpStatusLabel,
    int? heartRateBpm,
    DateTime? heartRateCheckedAt,
    List<int>? heartRateRecent,
    List<MedicationReminder>? medications,
    List<CareReminder>? otherReminders,
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
  ];
}