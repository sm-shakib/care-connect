enum MedicationStatus { taken, dueNow, upcoming }

class MedicationReminder {
  MedicationReminder({
    required this.id,
    required this.name,
    required this.dose,
    required this.scheduledTime,
    required this.status,
    this.takenAt,
  });

  final String id;
  final String name;
  final String dose;
  final DateTime scheduledTime;
  final MedicationStatus status;
  final DateTime? takenAt;

  MedicationReminder copyWith({
    MedicationStatus? status,
    DateTime? takenAt,
  }) {
    return MedicationReminder(
      id: id,
      name: name,
      dose: dose,
      scheduledTime: scheduledTime,
      status: status ?? this.status,
      takenAt: takenAt ?? this.takenAt,
    );
  }
}