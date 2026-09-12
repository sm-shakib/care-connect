import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// A single medication dose reminder shown on dashboards. This is a UI-centric
/// representation of a specific scheduled time for a [Medicine].
class Medication extends Equatable {
  const Medication({
    required this.id,
    required this.name,
    this.nameBn,
    required this.dosage,
    required this.time,
    this.isTaken = false,
  });

  final String id;
  final String name;
  final String? nameBn;
  final String dosage;

  /// Pre-formatted time label, e.g. "8:00 AM".
  final String time;
  final bool isTaken;

  /// Returns the localized name based on the current app locale.
  String getName(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'bn' &&
        nameBn != null &&
        nameBn!.isNotEmpty) {
      return nameBn!;
    }
    return name;
  }

  Medication copyWith({bool? isTaken}) {
    return Medication(
      id: id,
      name: name,
      nameBn: nameBn,
      dosage: dosage,
      time: time,
      isTaken: isTaken ?? this.isTaken,
    );
  }

  @override
  List<Object?> get props => [id, name, nameBn, dosage, time, isTaken];
}
