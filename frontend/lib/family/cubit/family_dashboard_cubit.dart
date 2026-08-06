import 'package:bloc/bloc.dart';
import 'package:frontend/family/data/elder_dummy_data.dart';
import '../models/appointment.dart';
import '../models/elder.dart';
import '../models/medication.dart';
import '../models/reminder.dart';
import 'family_dashboard_state.dart';

class FamilyDashboardCubit extends Cubit<FamilyDashboardState> {
  FamilyDashboardCubit() : super(const FamilyDashboardState()) {
    loadElders();
  }

  /// Load all elders
  void loadElders() {
    emit(
      state.copyWith(
        elders: elderList,
        filteredElders: elderList,
      ),
    );
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

  /// Medication Management
  void addMedication(String elderId, Medication medication) {
    final updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      return elder.copyWith(medications: [...elder.medications, medication]);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void updateMedication(String elderId, Medication medication) {
    final updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      final updatedMedications = elder.medications.map((m) {
        return m.id == medication.id ? medication : m;
      }).toList();
      return elder.copyWith(medications: updatedMedications);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void deleteMedication(String elderId, String medicationId) {
    final updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      final updatedMedications =
          elder.medications.where((m) => m.id != medicationId).toList();
      return elder.copyWith(medications: updatedMedications);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  /// Other Reminders Management
  void addReminder(String elderId, Reminder reminder) {
    final updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      return elder.copyWith(otherReminders: [...elder.otherReminders, reminder]);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void updateReminder(String elderId, Reminder reminder) {
    final updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      final updatedReminders = elder.otherReminders.map((r) {
        return r.id == reminder.id ? reminder : r;
      }).toList();
      return elder.copyWith(otherReminders: updatedReminders);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void deleteReminder(String elderId, String reminderId) {
    final updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      final updatedReminders =
          elder.otherReminders.where((r) => r.id != reminderId).toList();
      return elder.copyWith(otherReminders: updatedReminders);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  /// Appointment Management
  void addAppointment(String elderId, Appointment appointment) {
    final updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      return elder.copyWith(appointments: [...elder.appointments, appointment]);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void updateAppointment(String elderId, Appointment appointment) {
    final updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      final updatedAppointments = elder.appointments.map((a) {
        return a.id == appointment.id ? appointment : a;
      }).toList();
      return elder.copyWith(appointments: updatedAppointments);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }

  void deleteAppointment(String elderId, String appointmentId) {
    final updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;
      final updatedAppointments =
          elder.appointments.where((a) => a.id != appointmentId).toList();
      return elder.copyWith(appointments: updatedAppointments);
    }).toList();
    _emitUpdatedElders(updatedElders, elderId);
  }
}
