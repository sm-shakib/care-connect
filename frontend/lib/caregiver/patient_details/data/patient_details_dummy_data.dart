import 'package:flutter/material.dart';

import '../models/care_reminder.dart';
import '../models/medication_reminder.dart';

// TODO: replace with a real repository call keyed by patientId once the
// patient care-plan API exists.
class PatientDetailsDummyData {
  static List<MedicationReminder> medications() {
    final now = DateTime.now();
    return [
      MedicationReminder(
        id: 'm1',
        name: 'Metoprolol 25mg',
        dose: '1 tablet',
        scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
        status: MedicationStatus.taken,
        takenAt: DateTime(now.year, now.month, now.day, 8, 0),
      ),
      MedicationReminder(
        id: 'm2',
        name: 'Lisinopril 10mg',
        dose: '1 tablet',
        scheduledTime: DateTime(now.year, now.month, now.day, 13, 0),
        status: MedicationStatus.dueNow,
      ),
      MedicationReminder(
        id: 'm3',
        name: 'Atorvastatin 40mg',
        dose: '1 tablet',
        scheduledTime: DateTime(now.year, now.month, now.day, 20, 0),
        status: MedicationStatus.upcoming,
      ),
    ];
  }

  static List<CareReminder> otherReminders() {
    return const [
      CareReminder(
        id: 'r1',
        title: 'Physical Therapy',
        subtitle: 'Session at 2:00 PM',
        icon: Icons.fitness_center,
      ),
      CareReminder(
        id: 'r2',
        title: 'Hydration Goal',
        subtitle: '8 Glasses (4/8 reached)',
        icon: Icons.water_drop,
        iconColorIsError: true,
      ),
    ];
  }
}