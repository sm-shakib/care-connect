import '../models/appointment.dart';
import '../models/elder.dart';
import '../models/health_vitals.dart';
import '../models/medical_record.dart';
import '../models/medication.dart';

const elderList = [
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
      Medication(
        id: 'm1',
        name: 'Metformin',
        dosage: '500mg',
        time: '08:00 AM',
        isTaken: true,
      ),
      Medication(
        id: 'm2',
        name: 'Atorvastatin',
        dosage: '20mg',
        time: '09:00 PM',
        isTaken: false,
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
