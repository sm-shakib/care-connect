import 'package:flutter/material.dart';
import 'package:frontend/shared/medicine/models/medicine.dart';
import 'package:frontend/shared/reminders/models/appointment.dart';
import 'package:frontend/shared/reminders/models/care_reminder.dart';

import '../models/elder.dart';
import '../models/health_vitals.dart';
import '../models/medical_record.dart';

final _fourteenDaysAgo = DateTime.now().subtract(const Duration(days: 14));

// Not `const`: medications carry a runtime `startDate` (DateTime.now()-based).
final elderList = [
  Elder(
    id: '1',
    name: 'Abdul Karim',
    age: 72,
    relationship: 'Father',
    gender: 'Male',
    hasCaregiver: true,
    healthStatus: 'Healthy',
    caregivers: ['Sarah Jenkins', 'Michael Chen'],
    imageUrl: 'https://i.pravatar.cc/150?u=abdul',
    vitals: HealthVitals(
      heartRate: 72,
      heartRateStatus: 'Stable',
      systolic: 118,
      diastolic: 75,
      bpStatus: 'Normal Range',
    ),
    lastLocationUpdate: 'Updated 2 min ago',
    locationImage: 'assets/images/map.png',
    medications: [
      Medicine(
        id: 'm1',
        name: 'Metformin',
        dosage: '500mg',
        form: MedicineForm.tablet,
        timesPerDay: 1,
        scheduleTimes: ['08:00 AM'],
        startDate: _fourteenDaysAgo,
        isTakenToday: true,
      ),
      Medicine(
        id: 'm2',
        name: 'Atorvastatin',
        dosage: '20mg',
        form: MedicineForm.tablet,
        timesPerDay: 1,
        scheduleTimes: ['09:00 PM'],
        startDate: _fourteenDaysAgo,
      ),
    ],
    medicalRecords: [
      MedicalRecord(
        id: 'r1',
        title: 'Monthly Heart Checkup',
        date: 'Oct 24, 2023',
        doctorNote:
            'Heart rate is stable. Recommended to continue current medication and light walking.',
        healthStatus: 'Stable',
      ),
    ],
    appointments: [
      Appointment(
        id: 'a1',
        doctorName: 'Dr. Ariful Islam',
        specialty: 'Cardiologist',
        date: 'Nov 15, 2023',
        time: '10:30 AM',
        location: 'City Hospital, Dhaka',
      ),
    ],
    otherReminders: [
      CareReminder(
        id: 'rem1',
        title: 'Physical Therapy',
        subtitle: 'At 2:00 PM',
        icon: Icons.fitness_center,
      ),
      CareReminder(
        id: 'rem2',
        title: 'Hydration',
        subtitle: 'Drink 2L water',
        icon: Icons.water_drop,
      ),
    ],
  ),
  Elder(
    id: '2',
    name: 'Rahima Begum',
    age: 68,
    relationship: 'Mother',
    gender: 'Female',
    hasCaregiver: false,
    healthStatus: 'Needs Caregiver',
    imageUrl: 'https://i.pravatar.cc/150?u=rahima',
    vitals: HealthVitals(
      heartRate: 85,
      heartRateStatus: 'Slightly High',
      systolic: 135,
      diastolic: 88,
      bpStatus: 'Pre-hypertension',
    ),
    lastLocationUpdate: 'Updated 15 min ago',
    locationImage: 'assets/images/map.png',
    caregivers: [],
    medications: [],
    medicalRecords: [],
    appointments: [],
  ),
];
