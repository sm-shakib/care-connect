import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/family/data/repositories/binding_repository.dart';
import 'package:frontend/family/models/health_vitals.dart';
import 'package:frontend/shared/medicine/data/medicine_dto.dart';
import 'package:frontend/shared/medicine/models/medicine.dart';
import 'package:frontend/shared/reminders/models/appointment.dart';
import 'package:frontend/shared/reminders/models/care_reminder.dart';

import '../models/elder.dart';
import 'family_dashboard_state.dart';

class FamilyDashboardCubit extends Cubit<FamilyDashboardState> {
  final BindingRepository _bindingRepository;

  FamilyDashboardCubit(this._bindingRepository) : super(const FamilyDashboardState()) {
    loadElders();
  }

  /// Load real elders from backend
  Future<void> loadElders() async {
    try {
      final membersData = await _bindingRepository.getFamilyMembers();
      
      final List<Elder> elders = membersData.map((data) {
        final elderData = data['elder'];
        final relationship = data['relationship'];
        final dobStr = elderData['date_of_birth'] as String?;
        final dob = dobStr != null ? DateTime.tryParse(dobStr) : null;
        
        final medicationsRaw = data['medications'] as List? ?? [];
        final medications = medicationsRaw.map((m) => 
          MedicineDto.fromJson(m as Map<String, dynamic>).toEntity()
        ).toList();

        final appointmentsRaw = data['appointments'] as List? ?? [];
        final List<Appointment> appointments = appointmentsRaw.map((a) {
          final ad = a as Map<String, dynamic>;
          return Appointment(
            id: ad['id'].toString(),
            doctorName: ad['doctor_name'] as String,
            specialty: ad['specialty'] as String? ?? 'Specialist',
            date: ad['appointment_date'] as String,
            time: ad['appointment_time'] as String,
            location: ad['location'] as String? ?? 'Hospital',
          );
        }).toList();

        final remindersRaw = data['reminders'] as List? ?? [];
        final List<CareReminder> reminders = remindersRaw.map((r) {
          final rd = r as Map<String, dynamic>;
          return CareReminder(
            id: rd['id'].toString(),
            title: rd['title'] as String,
            subtitle: rd['subtitle'] as String? ?? '',
            icon: Icons.notifications_active_outlined,
          );
        }).toList();

        final List<String> caregiverNames = List<String>.from(data['caregiver_names'] as List? ?? []);
        final Map<String, String> caregiverIdMap = {};
        final caregiverDetails = data['caregiver_details'] as List? ?? [];
        for (final detail in caregiverDetails) {
          final d = detail as Map<String, dynamic>;
          caregiverIdMap[d['name'] as String] = (d['id'] as int).toString();
        }

        final hr = elderData['heart_rate'] as int? ?? 75;
        final systolic = elderData['systolic_bp'] as int? ?? 120;
        final diastolic = elderData['diastolic_bp'] as int? ?? 80;

        return Elder(
          id: elderData['id'].toString(),
          name: elderData['name'] as String,
          age: dob != null ? _calculateAge(dob) : 70,
          relationship: relationship as String,
          gender: elderData['gender'] as String? ?? 'Unknown',
          hasCaregiver: caregiverNames.isNotEmpty,
          healthStatus: elderData['health_condition'] as String? ?? 'Stable',
          imageUrl: elderData['profile_image_url'] as String? ?? '',
          caregivers: caregiverNames,
          caregiverIdMap: caregiverIdMap,
          vitals: HealthVitals(
            heartRate: hr,
            heartRateStatus: _getHeartRateStatus(hr),
            systolic: systolic,
            diastolic: diastolic,
            bpStatus: _getBPStatus(systolic, diastolic),
          ),
          lastLocationUpdate:
              elderData['last_location_update'] as String? ?? 'Just now',
          locationImage: 'assets/images/map.png',
          latitude: elderData['latitude'] as String?,
          longitude: elderData['longitude'] as String?,
          medications: medications,
          appointments: appointments,
          otherReminders: reminders,
        );
      }).toList();

      emit(
        state.copyWith(
          elders: elders,
          filteredElders: elders,
        ),
      );
    } catch (e) {
      debugPrint('FamilyDashboardCubit.loadElders error: $e');
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _getHeartRateStatus(int hr) {
    if (hr < 60) return 'Low';
    if (hr <= 100) return 'Normal';
    return 'High';
  }

  String _getBPStatus(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) return 'Normal';
    if (systolic < 130 && diastolic < 80) return 'Elevated';
    if (systolic < 140 || diastolic < 90) return 'Stage 1';
    return 'High';
  }

  /// Filter elders by name or relationship
  void searchElders(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(filteredElders: state.elders));
      return;
    }

    final filtered = state.elders.where((elder) {
      final nameMatch = elder.name.toLowerCase().contains(query.toLowerCase());
      final relationMatch =
          elder.relationship.toLowerCase().contains(query.toLowerCase());
      return nameMatch || relationMatch;
    }).toList();

    emit(state.copyWith(filteredElders: filtered));
  }

  /// Select an elder (pass null to go back to dashboard)
  void selectElder(Elder? elder) {
    emit(
      state.copyWith(
        selectedElder: () => elder,
      ),
    );
  }

  /// Start booking process for a specific elder
  void startBookingForElder(Elder elder) {
    emit(
      state.copyWith(
        bookingForElder: () => elder,
      ),
    );
  }

  /// Clear the booking context
  void clearBookingContext() {
    emit(
      state.copyWith(
        bookingForElder: () => null,
      ),
    );
  }

  /// Add a caregiver to a specific elder after successful booking
  void addCaregiverToElder(String elderId, String caregiverName) {
    final List<Elder> updatedElders = state.elders.map<Elder>((elder) {
      if (elder.id != elderId) return elder;

      // Avoid duplicates
      if (elder.caregivers.contains(caregiverName)) return elder;

      return elder.copyWith(
        caregivers: [...elder.caregivers, caregiverName],
        hasCaregiver: true,
        healthStatus: 'Healthy',
      );
    }).toList();

    _emitUpdatedElders(updatedElders, elderId);
  }

  void _emitUpdatedElders(List<Elder> updatedElders, String selectedElderId) {
    emit(
      state.copyWith(
        elders: updatedElders,
        filteredElders: updatedElders,
        // Update selected elder if currently viewing them
        selectedElder: state.selectedElder?.id == selectedElderId
            ? () => updatedElders.firstWhere((e) => e.id == selectedElderId)
            : () => state.selectedElder,
      ),
    );
  }

  void addMedication(String elderId, Medicine medication) {
    final List<Elder> updatedElders = state.elders.map<Elder>((elder) {
      if (elder.id != elderId) return elder;
      return elder.copyWith(medications: [...elder.medications, medication]);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void updateMedication(String elderId, Medicine medication) {
    final List<Elder> updatedElders = state.elders.map<Elder>((elder) {
      if (elder.id != elderId) return elder;
      final List<Medicine> updatedMedications = elder.medications.map<Medicine>((m) {
        return m.id == medication.id ? medication : m;
      }).toList();
      return elder.copyWith(medications: updatedMedications);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void deleteMedication(String elderId, String medicationId) {
    final List<Elder> updatedElders = state.elders.map<Elder>((elder) {
      if (elder.id != elderId) return elder;
      final List<Medicine> updatedMedications =
          elder.medications.where((m) => m.id != medicationId).toList();
      return elder.copyWith(medications: updatedMedications);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  /// Other Reminders Management
  void addReminder(String elderId, CareReminder reminder) {
    final List<Elder> updatedElders = state.elders.map<Elder>((elder) {
      if (elder.id != elderId) return elder;
      return elder.copyWith(otherReminders: [...elder.otherReminders, reminder]);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void updateReminder(String elderId, CareReminder reminder) {
    final List<Elder> updatedElders = state.elders.map<Elder>((elder) {
      if (elder.id != elderId) return elder;
      final List<CareReminder> updatedReminders = elder.otherReminders.map<CareReminder>((r) {
        return r.id == reminder.id ? reminder : r;
      }).toList();
      return elder.copyWith(otherReminders: updatedReminders);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void deleteReminder(String elderId, String reminderId) {
    final List<Elder> updatedElders = state.elders.map<Elder>((elder) {
      if (elder.id != elderId) return elder;
      final List<CareReminder> updatedReminders =
          elder.otherReminders.where((r) => r.id != reminderId).toList();
      return elder.copyWith(otherReminders: updatedReminders);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  /// Appointment Management
  void addAppointment(String elderId, Appointment appointment) {
    final List<Elder> updatedElders = state.elders.map<Elder>((elder) {
      if (elder.id != elderId) return elder;
      return elder.copyWith(appointments: [...elder.appointments, appointment]);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void updateAppointment(String elderId, Appointment appointment) {
    final List<Elder> updatedElders = state.elders.map<Elder>((elder) {
      if (elder.id != elderId) return elder;
      final List<Appointment> updatedAppointments = elder.appointments.map<Appointment>((a) {
        return a.id == appointment.id ? appointment : a;
      }).toList();
      return elder.copyWith(appointments: updatedAppointments);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void deleteAppointment(String elderId, String appointmentId) {
    final List<Elder> updatedElders = state.elders.map<Elder>((elder) {
      if (elder.id != elderId) return elder;
      final List<Appointment> updatedAppointments =
          elder.appointments.where((a) => a.id != appointmentId).toList();
      return elder.copyWith(appointments: updatedAppointments);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }
}
