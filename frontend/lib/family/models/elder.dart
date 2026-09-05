import 'package:equatable/equatable.dart';
import 'package:frontend/caregiver/models/booking_request.dart';
import 'package:frontend/shared/medicine/models/medicine.dart';
import 'package:frontend/shared/reminders/models/appointment.dart';
import 'package:frontend/shared/reminders/models/care_reminder.dart';

import 'health_vitals.dart';
import 'medical_record.dart';

class Elder extends Equatable {
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
    this.caregiverIdMap = const {},
    this.medications = const [],
    this.medicalRecords = const [],
    this.appointments = const [],
    this.otherReminders = const [],
    this.bookings = const [],
    this.latitude,
    this.longitude,
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
  final Map<String, String> caregiverIdMap; // Name -> ID mapping
  final List<Medicine> medications;
  final List<MedicalRecord> medicalRecords;
  final List<Appointment> appointments;
  final List<CareReminder> otherReminders;
  final List<BookingRequest> bookings;
  
  // New dynamic health fields
  final HealthVitals vitals;
  final String lastLocationUpdate;
  final String locationImage;

  final String? latitude;
  final String? longitude;

  Elder copyWith({
    String? id,
    String? name,
    int? age,
    String? relationship,
    String? gender,
    bool? hasCaregiver,
    String? healthStatus,
    String? imageUrl,
    List<String>? caregivers,
    Map<String, String>? caregiverIdMap,
    List<Medicine>? medications,
    List<MedicalRecord>? medicalRecords,
    List<Appointment>? appointments,
    List<CareReminder>? otherReminders,
    List<BookingRequest>? bookings,
    HealthVitals? vitals,
    String? lastLocationUpdate,
    String? locationImage,
    String? latitude,
    String? longitude,
  }) {
    return Elder(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      relationship: relationship ?? this.relationship,
      gender: gender ?? this.gender,
      hasCaregiver: hasCaregiver ?? this.hasCaregiver,
      healthStatus: healthStatus ?? this.healthStatus,
      imageUrl: imageUrl ?? this.imageUrl,
      caregivers: caregivers ?? this.caregivers,
      caregiverIdMap: caregiverIdMap ?? this.caregiverIdMap,
      medications: medications ?? this.medications,
      medicalRecords: medicalRecords ?? this.medicalRecords,
      appointments: appointments ?? this.appointments,
      otherReminders: otherReminders ?? this.otherReminders,
      bookings: bookings ?? this.bookings,
      vitals: vitals ?? this.vitals,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      locationImage: locationImage ?? this.locationImage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        relationship,
        gender,
        hasCaregiver,
        healthStatus,
        imageUrl,
        caregivers,
        caregiverIdMap,
        medications,
        medicalRecords,
        appointments,
        otherReminders,
        bookings,
        vitals,
        lastLocationUpdate,
        locationImage,
        latitude,
        longitude,
      ];
}
