import 'package:flutter/material.dart';

import 'package:frontend/core/enums/gender.dart';

import '../models/care_reminder.dart';
import '../models/medication_reminder.dart';

/// Basic info collected during the elderly's signup, shown read-only
/// on the patient details page.
class PatientBasicInfo {
  const PatientBasicInfo({
    required this.gender,
    required this.dateOfBirth,
    required this.phone,
    required this.email,
    required this.address,
  });

  final Gender gender;
  final DateTime dateOfBirth;
  final String phone;
  final String email;
  final String address;
}

// TODO: replace with a real repository call keyed by patientId once the
// patient care-plan API exists.
class PatientDetailsDummyData {
  static PatientBasicInfo basicInfo() {
    return PatientBasicInfo(
      gender: Gender.male,
      dateOfBirth: DateTime(1946, 3, 18),
      phone: '+8801717790950',
      email: 'karim@gmail.com',
      address: 'Pallabi, Dhaka',
    );
  }

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
      // CareReminder(
      //   id: 'r2',
      //   title: 'Hydration Goal',
      //   subtitle: '8 Glasses (4/8 reached)',
      //   icon: Icons.water_drop,
      //   iconColorIsError: true,
      // ),
    ];
  }
}