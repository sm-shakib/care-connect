import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/l10n/l10n.dart';

/// The physical form a medicine is taken in.
enum MedicineForm { tablet, capsule, syrup, injection, other }

extension MedicineFormLabel on MedicineForm {
  String label(BuildContext context) {
    switch (this) {
      case MedicineForm.tablet:
        return context.l10n.medicineFormTablet;
      case MedicineForm.capsule:
        return context.l10n.medicineFormCapsule;
      case MedicineForm.syrup:
        return context.l10n.medicineFormSyrup;
      case MedicineForm.injection:
        return context.l10n.medicineFormInjection;
      case MedicineForm.other:
        return context.l10n.medicineFormOther;
    }
  }
}

/// A medicine added by (or for) an elderly user, including its dosage
/// schedule and refill reminder settings.
class Medicine extends Equatable {
  const Medicine({
    required this.id,
    required this.name,
    this.nameBn,
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

  /// Default (English) name.
  final String name;

  /// Optional Bangla name.
  final String? nameBn;

  /// Returns the localized name based on the current app locale.
  String getName(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'bn' &&
        nameBn != null &&
        nameBn!.isNotEmpty) {
      return nameBn!;
    }
    return name;
  }

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
    String? nameBn,
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
      nameBn: nameBn ?? this.nameBn,
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
        nameBn,
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
