import 'appointment.dart';
import 'health_vitals.dart';
import 'medical_record.dart';
import 'medication.dart';

class Elder {
  const Elder({
    required this.id,
    required this.name,
    required this.age,
    required this.relationship,
    required this.gender,
    required this.hasCaregiver,
    required this.healthStatus,
    required this.vitals,
    required this.lastLocationUpdate,
    required this.locationImage,
    this.imageUrl = '',
    this.caregivers = const [],
    this.medications = const [],
    this.medicalRecords = const [],
    this.appointments = const [],
  });

  final String id;
  final String name;
  final int age;
  final String relationship;
  final String gender;
  final bool hasCaregiver;
  final String healthStatus;
  final String imageUrl;
  final List<String> caregivers;
  final List<Medication> medications;
  final List<MedicalRecord> medicalRecords;
  final List<Appointment> appointments;
  
  // New dynamic health fields
  final HealthVitals vitals;
  final String lastLocationUpdate;
  final String locationImage;
}
