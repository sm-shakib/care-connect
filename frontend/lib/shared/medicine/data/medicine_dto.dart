import 'package:intl/intl.dart';

import '../models/medicine.dart';

/// Maps [Medicine] to/from the JSON shape used by the `/medicines` backend
/// endpoints (snake_case keys, ISO date strings).
class MedicineDto {
  MedicineDto({
    this.id,
    required this.name,
    this.nameBn,
    required this.dosage,
    required this.form,
    this.imageUrl,
    required this.timesPerDay,
    required this.scheduleTimes,
    required this.startDate,
    required this.endDate,
    required this.refillReminderEnabled,
    required this.availableUnits,
    required this.notifyThreshold,
    this.takenDoseTimes = const [],
  });

  final int? id;
  final String name;
  final String? nameBn;
  final String dosage;
  final MedicineForm form;
  final String? imageUrl;
  final int timesPerDay;
  final List<String> scheduleTimes;
  final DateTime startDate;
  final DateTime endDate;
  final bool refillReminderEnabled;
  final int availableUnits;
  final int notifyThreshold;
  final List<String> takenDoseTimes;

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  factory MedicineDto.fromJson(Map<String, dynamic> json) {
    return MedicineDto(
      id: json['id'] as int,
      name: json['name'] as String,
      nameBn: json['name_bn'] as String?,
      dosage: json['dosage'] as String,
      form: _parseForm(json['form'] as String),
      imageUrl: json['image_url'] as String?,
      timesPerDay: json['times_per_day'] as int,
      scheduleTimes: List<String>.from(json['schedule_times'] as List),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      refillReminderEnabled: json['refill_reminder_enabled'] as bool? ?? false,
      availableUnits: json['available_units'] as int? ?? 0,
      notifyThreshold: json['notify_threshold'] as int? ?? 0,
      takenDoseTimes: List<String>.from(json['taken_dose_times'] as List? ?? const []),
    );
  }

  factory MedicineDto.fromEntity(Medicine medicine) {
    return MedicineDto(
      id: int.tryParse(medicine.id),
      name: medicine.name,
      nameBn: medicine.nameBn,
      dosage: medicine.dosage,
      form: medicine.form,
      imageUrl: medicine.imagePath,
      timesPerDay: medicine.timesPerDay,
      scheduleTimes: medicine.scheduleTimes,
      startDate: medicine.startDate,
      endDate: medicine.endDate,
      refillReminderEnabled: medicine.refillReminderEnabled,
      availableUnits: medicine.availableUnits,
      notifyThreshold: medicine.notifyThreshold,
      takenDoseTimes: medicine.takenDoseTimes,
    );
  }

  Medicine toEntity() {
    return Medicine(
      id: id?.toString() ?? '',
      name: name,
      nameBn: nameBn,
      dosage: dosage,
      form: form,
      imagePath: imageUrl,
      timesPerDay: timesPerDay,
      scheduleTimes: scheduleTimes,
      startDate: startDate,
      endDate: endDate,
      refillReminderEnabled: refillReminderEnabled,
      availableUnits: availableUnits,
      notifyThreshold: notifyThreshold,
      takenDoseTimes: takenDoseTimes,
    );
  }

  /// Body for create/update requests. `id` is never sent — it's assigned
  /// by the server (create) or taken from the URL (update).
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'name_bn': nameBn,
      'dosage': dosage,
      'form': form.name,
      'image_url': imageUrl,
      'times_per_day': timesPerDay,
      'schedule_times': scheduleTimes,
      'start_date': _dateFormat.format(startDate),
      'end_date': _dateFormat.format(endDate),
      'refill_reminder_enabled': refillReminderEnabled,
      'available_units': availableUnits,
      'notify_threshold': notifyThreshold,
    };
  }

  static MedicineForm _parseForm(String value) {
    return MedicineForm.values.firstWhere(
      (form) => form.name == value,
      orElse: () => MedicineForm.other,
    );
  }
}
