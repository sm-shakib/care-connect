import 'package:bloc/bloc.dart';
import 'package:frontend/family/data/repositories/binding_repository.dart';
import 'package:frontend/family/models/health_vitals.dart';
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
      
      final elders = membersData.map((data) {
        final elderData = data['elder'];
        final relationship = data['relationship'];
        
        return Elder(
          id: elderData['id'].toString(),
          name: elderData['name'],
          age: 70, // TODO: Calculate from date_of_birth
          relationship: relationship,
          gender: elderData['gender'] ?? 'Unknown',
          hasCaregiver: false,
          healthStatus: elderData['health_condition'] ?? 'Stable',
          imageUrl: elderData['profile_image_url'] ?? '',
          vitals: const HealthVitals(
            heartRate: 75,
            heartRateStatus: 'Normal',
            systolic: 120,
            diastolic: 80,
            bpStatus: 'Normal',
          ),
          lastLocationUpdate: 'Just now',
          locationImage: 'assets/images/map.png',
        );
      }).toList();

      emit(
        state.copyWith(
          elders: elders,
          filteredElders: elders,
        ),
      );
    } catch (e) {
      // Handle error
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
    final List<Elder> updatedElders = state.elders.map((elder) {
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
    final List<Elder> updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      return elder.copyWith(medications: [...elder.medications, medication]);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void updateMedication(String elderId, Medicine medication) {
    final List<Elder> updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      final updatedMedications = elder.medications.map((m) {
        return m.id == medication.id ? medication : m;
      }).toList();
      return elder.copyWith(medications: updatedMedications);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void deleteMedication(String elderId, String medicationId) {
    final List<Elder> updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      final updatedMedications =
          elder.medications.where((m) => m.id != medicationId).toList();
      return elder.copyWith(medications: updatedMedications);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  /// Other Reminders Management
  void addReminder(String elderId, CareReminder reminder) {
    final List<Elder> updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      return elder.copyWith(otherReminders: [...elder.otherReminders, reminder]);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void updateReminder(String elderId, CareReminder reminder) {
    final List<Elder> updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      final updatedReminders = elder.otherReminders.map((r) {
        return r.id == reminder.id ? reminder : r;
      }).toList();
      return elder.copyWith(otherReminders: updatedReminders);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void deleteReminder(String elderId, String reminderId) {
    final List<Elder> updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      final updatedReminders =
          elder.otherReminders.where((r) => r.id != reminderId).toList();
      return elder.copyWith(otherReminders: updatedReminders);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  /// Appointment Management
  void addAppointment(String elderId, Appointment appointment) {
    final List<Elder> updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      return elder.copyWith(appointments: [...elder.appointments, appointment]);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void updateAppointment(String elderId, Appointment appointment) {
    final List<Elder> updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      final updatedAppointments = elder.appointments.map((a) {
        return a.id == appointment.id ? appointment : a;
      }).toList();
      return elder.copyWith(appointments: updatedAppointments);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void deleteAppointment(String elderId, String appointmentId) {
    final List<Elder> updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      final updatedAppointments =
          elder.appointments.where((a) => a.id != appointmentId).toList();
      return elder.copyWith(appointments: updatedAppointments);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }
}
