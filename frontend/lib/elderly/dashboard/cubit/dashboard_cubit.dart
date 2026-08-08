import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/family/models/binding_request.dart';
import 'package:frontend/shared/reminders/models/appointment.dart';
import 'package:frontend/shared/reminders/models/care_reminder.dart';

import 'dashboard_models.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      // TODO(careconnect): replace with repository call to FastAPI backend.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          userName: 'Adib',
          medications: _mockMedications,
          otherReminders: _mockOtherReminders,
          appointments: _mockAppointments,
          caregiver: _mockCaregiver,
          chatPreview: _mockChatPreview,
          bindingRequests: _mockRequests,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: 'Unable to load your dashboard. Please try again.',
        ),
      );
    }
  }

  void markMedicationTaken(String medicationId) {
    final updated = state.medications.map((medication) {
      if (medication.id != medicationId) return medication;
      return medication.copyWith(isTaken: true);
    }).toList();
    emit(state.copyWith(medications: updated));
  }

  // ---- Other reminders / appointments editing (Add / Modify / Delete) ----
  // TODO: sync these changes to a real backend once the care-plan API exists.

  void addReminder(CareReminder reminder) {
    emit(state.copyWith(otherReminders: [...state.otherReminders, reminder]));
  }

  void updateReminder(CareReminder reminder) {
    final updated =
        state.otherReminders.map((r) => r.id == reminder.id ? reminder : r).toList();
    emit(state.copyWith(otherReminders: updated));
  }

  void deleteReminder(String reminderId) {
    final updated = state.otherReminders.where((r) => r.id != reminderId).toList();
    emit(state.copyWith(otherReminders: updated));
  }

  void addAppointment(Appointment appointment) {
    emit(state.copyWith(appointments: [...state.appointments, appointment]));
  }

  void updateAppointment(Appointment appointment) {
    final updated =
        state.appointments.map((a) => a.id == appointment.id ? appointment : a).toList();
    emit(state.copyWith(appointments: updated));
  }

  void deleteAppointment(String appointmentId) {
    final updated = state.appointments.where((a) => a.id != appointmentId).toList();
    emit(state.copyWith(appointments: updated));
  }

  void updateRequestStatus(String requestId, BindingStatus status) {
    // In a real app, this would be a backend call
    final updatedRequests = state.bindingRequests.map((req) {
      if (req.id != requestId) return req;
      return req.copyWith(status: status);
    }).where((req) => req.status == BindingStatus.pending).toList();

    emit(state.copyWith(bindingRequests: updatedRequests));
  }

  static final _mockRequests = [
    BindingRequest(
      id: 'req_1',
      elderId: 'elder_123',
      familyId: 'fam_456',
      familyName: 'John Doe',
      relationship: 'Father',
      status: BindingStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    BindingRequest(
      id: 'req_2',
      elderId: 'elder_123',
      familyId: 'fam_789',
      familyName: 'Jane Smith',
      relationship: 'Grandmother',
      status: BindingStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static const _mockMedications = [
    Medication(
      id: 'M-1',
      name: 'Metformin',
      dosage: '500mg, 1 tablet',
      time: '8:00 AM',
      isTaken: true,
    ),
    Medication(
      id: 'M-2',
      name: 'Lisinopril',
      dosage: '10mg, 1 tablet',
      time: '1:00 PM',
    ),
    Medication(
      id: 'M-3',
      name: 'Atorvastatin',
      dosage: '20mg, 1 tablet',
      time: '9:00 PM',
    ),
  ];

  static const _mockOtherReminders = [
    CareReminder(
      id: 'rem_1',
      title: 'Physical Therapy',
      subtitle: 'At 2:00 PM',
      icon: Icons.fitness_center,
    ),
    CareReminder(
      id: 'rem_2',
      title: 'Hydration',
      subtitle: 'Drink 2L water',
      icon: Icons.water_drop,
    ),
  ];

  static const _mockAppointments = [
    Appointment(
      id: 'apt_1',
      doctorName: 'Dr. Ariful Islam',
      specialty: 'Cardiologist',
      date: 'Aug 16, 2026',
      time: '10:30 AM',
      location: 'City Hospital, Dhaka',
    ),
  ];

  static const _mockCaregiver = CaregiverSummary(
    id: 'C-1',
    name: 'Nusrat Jahan',
    profession: 'Registered Nurse',
    nextVisitLabel: 'Today, 3:00 PM',
    phone: '+1 555-0134',
  );

  static const _mockChatPreview = ChatPreview(
    senderName: 'Lamine Yamal',
    lastMessage: "Don't forget your afternoon walk today!",
    timeLabel: '10 min ago',
    unreadCount: 2,
  );
}
