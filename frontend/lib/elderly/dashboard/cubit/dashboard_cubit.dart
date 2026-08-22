import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/family/data/repositories/binding_repository.dart';
import 'package:frontend/family/models/binding_request.dart';
import 'package:frontend/shared/reminders/models/appointment.dart';
import 'package:frontend/shared/reminders/models/care_reminder.dart';

import 'dashboard_models.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final BindingRepository _bindingRepository;

  DashboardCubit(this._bindingRepository) : super(const DashboardState());

  Future<void> loadDashboardWithAuth(AuthRepository authRepository) async {
    await loadDashboard();
  }

  Future<void> loadDashboard() async {
    print('DEBUG: loadDashboard called');
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final requests = await _bindingRepository.getPendingRequests();
      print('DEBUG: Fetched ${requests.length} requests');

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          userName: 'Hello', // TODO: Fetch real name from profile API
          otherReminders: _mockOtherReminders,
          appointments: _mockAppointments,
          caregiver: _mockCaregiver,
          chatPreview: _mockChatPreview,
          bindingRequests: requests,
        ),
      );
    } catch (e) {
      print('DEBUG: loadDashboard error: $e');
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: 'Unable to load your dashboard: ${e.toString()}',
        ),
      );
    }
  }

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

  void updateRequestStatus(String requestId, BindingStatus status) async {
    try {
      final bindingId = int.parse(requestId);
      await _bindingRepository.respondToRequest(bindingId, status);
      
      final updatedRequests = state.bindingRequests.where((req) => req.id != requestId).toList();
      emit(state.copyWith(bindingRequests: updatedRequests));
    } catch (e) {
      // Handle error
    }
  }

  // ... rest of the mock data kept for UI stability ...
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
