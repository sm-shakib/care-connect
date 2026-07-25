import 'package:equatable/equatable.dart';

/// The physical form a medicine is taken in.
enum MedicineForm { tablet, capsule, syrup, injection, other }

extension MedicineFormLabel on MedicineForm {
  String get label {
    switch (this) {
      case MedicineForm.tablet:
        return 'Tablet';
      case MedicineForm.capsule:
        return 'Capsule';
      case MedicineForm.syrup:
        return 'Syrup';
      case MedicineForm.injection:
        return 'Injection';
      case MedicineForm.other:
        return 'Other';
    }
  }
}

/// A medicine added by (or for) an elderly user, including its dosage
/// schedule and refill reminder settings.
class Medicine extends Equatable {
  const Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.form,
    required this.timesPerDay,
    required this.scheduleTimes,
    required this.startDate,
    this.imagePath,
    this.refillReminderEnabled = false,
    this.availableUnits = 0,
    this.notifyThreshold = 0,
    this.isTakenToday = false,
  });

  final String id;
  final String name;

  /// How many units should be consumed per intake, e.g. "1 tablet".
  final String dosage;
  final MedicineForm form;
  final String? imagePath;

  final int timesPerDay;

  /// Pre-formatted time labels, e.g. ["8:00 AM", "9:00 PM"].
  final List<String> scheduleTimes;
  final DateTime startDate;

  final bool refillReminderEnabled;
  final int availableUnits;
  final int notifyThreshold;

  final bool isTakenToday;

  /// The next upcoming schedule time today, or the first one if none left.
  String get nextReminder =>
      scheduleTimes.isEmpty ? '--' : scheduleTimes.first;

  bool get isRefillLow =>
      refillReminderEnabled && availableUnits <= notifyThreshold;

  Medicine copyWith({
    String? name,
    String? dosage,
    MedicineForm? form,
    String? imagePath,
    int? timesPerDay,
    List<String>? scheduleTimes,
    DateTime? startDate,
    bool? refillReminderEnabled,
    int? availableUnits,
    int? notifyThreshold,
    bool? isTakenToday,
  }) {
    return Medicine(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      imagePath: imagePath ?? this.imagePath,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      scheduleTimes: scheduleTimes ?? this.scheduleTimes,
      startDate: startDate ?? this.startDate,
      refillReminderEnabled:
          refillReminderEnabled ?? this.refillReminderEnabled,
      availableUnits: availableUnits ?? this.availableUnits,
      notifyThreshold: notifyThreshold ?? this.notifyThreshold,
      isTakenToday: isTakenToday ?? this.isTakenToday,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    dosage,
    form,
    imagePath,
    timesPerDay,
    scheduleTimes,
    startDate,
    refillReminderEnabled,
    availableUnits,
    notifyThreshold,
    isTakenToday,
  ];
}
