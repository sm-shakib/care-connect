import 'package:flutter/material.dart';

import '../models/patient.dart';

// TODO: replace with a real repository call once the patients API exists.
final List<Patient> patientDummyData = [
  Patient(
    id: 'p1',
    name: 'Abdul Karim',
    age: 82,
    location: 'Pallabi, Dhaka',
    //conditionLabel: 'Hypertension Management',
    //conditionIcon: Icons.medical_services,
    status: PatientCareStatus.active,
  ),
  Patient(
    id: 'p2',
    name: 'Sharif Ahmed',
    age: 79,
    location: 'Dhanmondi, Dhaka',
    //conditionLabel: 'Post-Op Recovery - Watch Pulse',
    //conditionIcon: Icons.warning,
    status: PatientCareStatus.active,
    isUrgent: true,
  ),
  Patient(
    id: 'p3',
    name: 'Mahfujur Rahman',
    age: 91,
    location: 'Kalabagan, Dhaka',
    //conditionLabel: 'Early Stage Memory Care',
    //conditionIcon: Icons.psychology,
    status: PatientCareStatus.active,
  ),
  // Patient(
  //   id: 'p4',
  //   name: 'Anisul Haque',
  //   age: 85,
  //   location: 'Shewrapara, Dhaka',
  //   //conditionLabel: 'Post-Stroke Physiotherapy',
  //   //conditionIcon: Icons.monitor_heart,
  //   status: PatientCareStatus.active,
  // ),
  Patient(
    id: 'p5',
    name: 'Akhter Ali',
    age: 88,
    location: 'Zigatola, Dhaka',
    //conditionLabel: 'Discharged - Full Recovery',
    //conditionIcon: Icons.check_circle,
    status: PatientCareStatus.previous,
  ),
  Patient(
    id: 'p6',
    name: 'Rahim Uddin',
    age: 76,
    location: 'Banani, Dhaka',
    //conditionLabel: 'Discharged - Transferred Care',
    //conditionIcon: Icons.check_circle,
    status: PatientCareStatus.previous,
  ),
];