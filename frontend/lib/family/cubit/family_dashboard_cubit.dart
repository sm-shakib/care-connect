import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/caregiver/models/booking_request.dart';
import 'package:frontend/family/data/repositories/binding_repository.dart';
import 'package:frontend/family/models/health_vitals.dart';
import 'package:frontend/shared/medicine/data/medicine_dto.dart';
import 'package:frontend/shared/medicine/data/medicine_repository.dart';
import 'package:frontend/shared/medicine/models/medicine.dart';
import 'package:frontend/shared/reminders/models/appointment.dart';
import 'package:frontend/shared/reminders/models/care_reminder.dart';

import 'package:frontend/elderly/data/repositories/elder_repository.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/elder.dart';
import 'family_dashboard_state.dart';

class FamilyDashboardCubit extends Cubit<FamilyDashboardState> {
  final BindingRepository _bindingRepository;
  final _elderRepository = ElderRepository(ApiClient());
  final _medicineRepository = MedicineRepository(ApiClient());

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
            doctorName: (ad['doctor_name'] ?? '') as String,
            specialty: ad['specialty']?.toString() ?? '',
            date: ad['appointment_date']?.toString() ?? '',
            time: ad['appointment_time']?.toString() ?? '',
            location: ad['location']?.toString() ?? '',
          );
        }).toList();

        final remindersRaw = data['reminders'] as List? ?? [];
        final List<CareReminder> reminders = remindersRaw.map((r) {
          final rd = r as Map<String, dynamic>;
          final iconName = rd['icon_name']?.toString() ?? 'notifications';
          return CareReminder(
            id: rd['id'].toString(),
            title: (rd['title'] ?? '') as String,
            subtitle: rd['subtitle'] as String? ?? '',
            icon: CareReminder.mapIconNameToData(iconName),
          );
        }).toList();

        final bookingsRaw = data['bookings'] as List? ?? [];
        final List<BookingRequest> bookings = bookingsRaw.map((b) {
          return BookingRequest.fromJson(b as Map<String, dynamic>);
        }).toList();

        final List<String> caregiverNames =
            List<String>.from(data['caregiver_names'] as List? ?? []);
        final Map<String, String> caregiverIdMap = {};
        final caregiverDetails = data['caregiver_details'] as List? ?? [];
        for (final detail in caregiverDetails) {
          final d = detail as Map<String, dynamic>;
          caregiverIdMap[(d['name'] ?? '') as String] = (d['id'] ?? 0).toString();
        }

        final hr = elderData['heart_rate'] as int? ?? 75;
        final systolic = elderData['systolic_bp'] as int? ?? 120;
        final diastolic = elderData['diastolic_bp'] as int? ?? 80;

        return Elder(
          id: elderData['id'].toString(),
          name: elderData['name']?.toString() ?? 'Unknown',
          age: dob != null ? _calculateAge(dob) : 70,
          relationship: relationship?.toString() ?? 'Unknown',
          gender: elderData['gender']?.toString() ?? 'Unknown',
          hasCaregiver: caregiverNames.isNotEmpty,
          healthStatus: elderData['health_condition']?.toString() ?? 'Stable',
          imageUrl: elderData['profile_image_url']?.toString() ?? '',
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
          elderData['last_location_update']?.toString() ?? 'Just now',
          locationImage: 'assets/images/map.png',
          latitude: elderData['latitude']?.toString(),
          longitude: elderData['longitude']?.toString(),
          medications: medications,
          appointments: appointments,
          otherReminders: reminders,
          bookings: bookings,
        );
      }).toList();

      emit(
        state.copyWith(
          elders: elders,
          filteredElders: elders,
          // Keep the booking context updated with the latest elder data
          bookingForElder: state.bookingForElder != null
              ? () => elders.firstWhere(
                    (e) => e.id == state.bookingForElder!.id,
                    orElse: () => state.bookingForElder!,
                  )
              : null,
          // Also update selected elder if viewing one
          selectedElder: state.selectedElder != null
              ? () => elders.firstWhere(
                    (e) => e.id == state.selectedElder!.id,
                    orElse: () => state.selectedElder!,
                  )
              : null,
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

  Future<void> updateElderVitals(String elderId, int hr, int systolic, int diastolic) async {
    try {
      await _elderRepository.updateElderVitals(
        elderId: elderId,
        heartRate: hr,
        systolic: systolic,
        diastolic: diastolic,
      );
      // Reload elders to show updated values
      await loadElders();
    } catch (e) {
      debugPrint('Error updating elder vitals: $e');
    }
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

  void addMedication(String elderId, Medicine medication) async {
    try {
      final id = int.tryParse(elderId);
      if (id == null) return;
      
      // Optimistic update
      final currentElders = state.elders;
      final updatedElders = state.elders.map((elder) {
        if (elder.id != elderId) return elder;
        return elder.copyWith(
          medications: [...elder.medications, medication],
        );
      }).toList();
      _emitUpdatedElders(updatedElders, elderId);

      await _medicineRepository.createMedicine(medication, elderId: id);
      await loadElders();
    } catch (e) {
      debugPrint('Error adding medication: $e');
      await loadElders();
    }
  }

  void updateMedication(String elderId, Medicine medication) async {
    try {
      await _medicineRepository.updateMedicine(medication);
      await loadElders();
    } catch (e) {
      debugPrint('Error updating medication: $e');
    }
  }

  void deleteMedication(String elderId, String medicationId) async {
    // Optimistic update
    final currentElders = state.elders;
    final updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      return elder.copyWith(
        medications: elder.medications.where((m) => m.id != medicationId).toList(),
      );
    }).toList();
    
    _emitUpdatedElders(updatedElders, elderId);

    try {
      if (!medicationId.startsWith('MED-')) {
        await _medicineRepository.deleteMedicine(medicationId);
      }
      // Give the backend a moment to settle before refreshing
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await loadElders();
    } catch (e) {
      debugPrint('Error deleting medication: $e');
      // Rollback
      emit(state.copyWith(
        elders: currentElders,
        filteredElders: currentElders,
      ));
    }
  }

  void addReminder(String elderId, CareReminder reminder) async {
    try {
      final id = int.tryParse(elderId);
      if (id == null) return;
      await _elderRepository.addReminder({
        'title': reminder.title,
        'subtitle': reminder.subtitle,
        'icon_name': CareReminder.mapIconDataToName(reminder.icon),
      }, elderId: id);
      await loadElders();
    } catch (e) {
      debugPrint('Error adding reminder: $e');
    }
  }

  void updateReminder(String elderId, CareReminder reminder) async {
    try {
      final reminderId = int.tryParse(reminder.id);
      if (reminderId == null) return;
      await _elderRepository.updateReminder(reminderId, {
        'title': reminder.title,
        'subtitle': reminder.subtitle,
        'icon_name': CareReminder.mapIconDataToName(reminder.icon),
      });
      await loadElders();
    } catch (e) {
      debugPrint('Error updating reminder: $e');
    }
  }

  void deleteReminder(String elderId, String reminderId) async {
    // Optimistic update
    final currentElders = state.elders;
    final updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      return elder.copyWith(
        otherReminders: elder.otherReminders.where((r) => r.id != reminderId).toList(),
      );
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);

    try {
      final id = int.tryParse(reminderId);
      if (id != null) {
        await _elderRepository.deleteReminder(id);
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await loadElders();
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      emit(state.copyWith(
        elders: currentElders,
        filteredElders: currentElders,
      ));
    }
  }

  void addAppointment(String elderId, Appointment appointment) async {
    try {
      final id = int.tryParse(elderId);
      if (id == null) return;
      await _elderRepository.addAppointment({
        'doctor_name': appointment.doctorName,
        'specialty': appointment.specialty,
        'appointment_date': appointment.date,
        'appointment_time': appointment.time,
        'location': appointment.location,
      }, elderId: id);
      await loadElders();
    } catch (e) {
      debugPrint('Error adding appointment: $e');
    }
  }

  void updateAppointment(String elderId, Appointment appointment) async {
    try {
      final appointmentId = int.tryParse(appointment.id);
      if (appointmentId == null) return;
      await _elderRepository.updateAppointment(appointmentId, {
        'doctor_name': appointment.doctorName,
        'specialty': appointment.specialty,
        'appointment_date': appointment.date,
        'appointment_time': appointment.time,
        'location': appointment.location,
      });
      await loadElders();
    } catch (e) {
      debugPrint('Error updating appointment: $e');
    }
  }

  void deleteAppointment(String elderId, String appointmentId) async {
    // Optimistic update
    final currentElders = state.elders;
    final updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      return elder.copyWith(
        appointments: elder.appointments.where((a) => a.id != appointmentId).toList(),
      );
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);

    try {
      final id = int.tryParse(appointmentId);
      if (id != null) {
        await _elderRepository.deleteAppointment(id);
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await loadElders();
    } catch (e) {
      debugPrint('Error deleting appointment: $e');
      emit(state.copyWith(
        elders: currentElders,
        filteredElders: currentElders,
      ));
    }
  }
}
