import 'dart:convert';

import 'package:flutter/widgets.dart';

/// Everything the full-screen alarm needs to render and act, carried as a
/// notification's payload so the alarm can display correctly even from a
/// cold start — before any [Medicine] list has been loaded from the
/// backend.
class MedicineAlarmArgs {
  const MedicineAlarmArgs({
    required this.medicineId,
    required this.time,
    required this.name,
    this.nameBn,
    required this.dosage,
    this.imagePath,
  });

  final String medicineId;

  /// The specific scheduled time this alarm is for, e.g. "8:00 AM".
  final String time;
  final String name;
  final String? nameBn;
  final String dosage;
  final String? imagePath;

  /// Returns the localized name based on the current app locale, mirroring
  /// [Medicine.getName].
  String getName(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'bn' &&
        nameBn != null &&
        nameBn!.isNotEmpty) {
      return nameBn!;
    }
    return name;
  }

  String encode() => jsonEncode({
        'medicineId': medicineId,
        'time': time,
        'name': name,
        'nameBn': nameBn,
        'dosage': dosage,
        'imagePath': imagePath,
      });

  factory MedicineAlarmArgs.decode(String payload) {
    final json = jsonDecode(payload) as Map<String, dynamic>;
    return MedicineAlarmArgs(
      medicineId: json['medicineId'] as String,
      time: json['time'] as String,
      name: json['name'] as String,
      nameBn: json['nameBn'] as String?,
      dosage: json['dosage'] as String,
      imagePath: json['imagePath'] as String?,
    );
  }
}
