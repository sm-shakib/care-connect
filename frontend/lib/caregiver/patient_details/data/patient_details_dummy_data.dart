import 'package:flutter/material.dart';

import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/shared/medicine/models/medicine.dart';
import 'package:frontend/shared/reminders/models/appointment.dart';
import 'package:frontend/shared/reminders/models/care_reminder.dart';

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

  static List<Medicine> medications() {
    final now = DateTime.now();
    return [
      Medicine(
        id: 'm1',
        name: 'Metoprolol',
        dosage: '25mg',
        form: MedicineForm.tablet,
        timesPerDay: 1,
        scheduleTimes: const ['8:00 AM'],
        startDate: now.subtract(const Duration(days: 30)),
        isTakenToday: true,
      ),
      Medicine(
        id: 'm2',
        name: 'Lisinopril',
        dosage: '10mg',
        form: MedicineForm.tablet,
        timesPerDay: 1,
        scheduleTimes: const ['1:00 PM'],
        startDate: now.subtract(const Duration(days: 30)),
      ),
      Medicine(
        id: 'm3',
        name: 'Atorvastatin',
        dosage: '40mg',
        form: MedicineForm.tablet,
        timesPerDay: 1,
        scheduleTimes: const ['8:00 PM'],
        startDate: now.subtract(const Duration(days: 30)),
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
    ];
  }

  static List<Appointment> appointments() {
    return const [
      Appointment(
        id: 'a1',
        doctorName: 'Dr. Ariful Islam',
        specialty: 'Cardiologist',
        date: 'Nov 15, 2023',
        time: '10:30 AM',
        location: 'City Hospital, Dhaka',
      ),
    ];
  }
}
