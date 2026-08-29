import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/core/services/location_service.dart';
import 'package:frontend/elderly/data/repositories/elder_repository.dart';
import 'package:frontend/family/data/repositories/binding_repository.dart';
import 'package:frontend/caregiver/data/repositories/booking_repository.dart';
import 'package:frontend/caregiver/models/booking_request.dart';
import 'package:frontend/family/models/binding_request.dart';
import 'package:frontend/shared/reminders/models/appointment.dart';
import 'package:frontend/shared/reminders/models/care_reminder.dart';

import 'dashboard_models.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final BindingRepository _bindingRepository;
  final _bookingRepository = BookingRepository();
  final _authRepository = AuthRepository();
  final _elderRepository = ElderRepository(ApiClient());
  final _locationService = LocationService();
  StreamSubscription? _locationSubscription;
  Timer? _vitalsTimer;

  DashboardCubit(this._bindingRepository) : super(const DashboardState());

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _vitalsTimer?.cancel();
    return super.close();
  }

  Future<void> loadDashboardWithAuth(AuthRepository authRepository) async {
    await loadDashboard();
  }

  Future<void> loadDashboard() async {
    print('DEBUG: loadDashboard called');
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final profileId = await _authRepository.getProfileId();
      final requests = await _bindingRepository.getPendingRequests();
      
      // Fetch real data from backend
      final appointmentsData = await _elderRepository.getAppointments();
      final remindersData = await _elderRepository.getReminders();

      final appointments = appointmentsData.map((a) => Appointment(
        id: a['id'].toString(),
        doctorName: a['doctor_name'],
        specialty: a['specialty'] ?? '',
        date: a['appointment_date'],
        time: a['appointment_time'],
        location: a['location'] ?? '',
      )).toList();

      final reminders = remindersData.map((r) => CareReminder(
        id: r['id'].toString(),
        title: r['title'],
        subtitle: r['subtitle'] ?? '',
        icon: Icons.notifications_active_outlined, // Default icon
      )).toList();

      // Start real-time location tracking
      _startLocationTracking();
      
      // Start periodic health vitals simulation
      _startVitalsSimulation();

      CaregiverSummary? caregiver;
      if (profileId != null) {
        final bookings = await _bookingRepository.getElderBookings(profileId);

        final realAccepted = bookings
            .where((b) => b.status == BookingStatus.accepted)
            .toList();

        if (realAccepted.isNotEmpty) {
          final b = realAccepted.first;
          caregiver = CaregiverSummary(
            id: b.caregiverId.toString(),
            name: b.caregiverName,
            profession: b.caregiverProfession,
            nextVisitLabel: 'Today, ${b.timingLabel.split('—')[0].trim()}',
            phone: b.caregiverPhone,
            entity: b.caregiverEntity,
            booking: b,
          );
        }
      }

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          userName: 'Hello', // TODO: Fetch real name from profile API
          otherReminders: reminders,
          appointments: appointments,
          caregiver: caregiver,
          chatPreview: null,
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

  void _startVitalsSimulation() {
    _vitalsTimer?.cancel();
    _vitalsTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      final random = DateTime.now().second;
      _elderRepository.updateVitalsAndLocation(
        heartRate: 70 + (random % 20), // 70-90
        systolicBp: 115 + (random % 10), // 115-125
        diastolicBp: 75 + (random % 10), // 75-85
      );
      debugPrint('DEBUG: Vitals updated in backend');
    });
  }

  void _startLocationTracking() async {
    // Cancel existing subscription if any
    await _locationSubscription?.cancel();

    // Request permissions and get initial location
    final initialPos = await _locationService.getCurrentLocation();
    if (initialPos != null) {
      _updateBackendLocation(initialPos);
    }

    // Subscribe to continuous updates
    _locationSubscription = _locationService.getLocationStream().listen(
      (position) {
        _updateBackendLocation(position);
      },
      onError: (e) => debugPrint('Location tracking error: $e'),
    );
  }

  Future<void> _updateBackendLocation(dynamic position) async {
    try {
      await _elderRepository.updateVitalsAndLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      debugPrint('DEBUG: Backend updated with location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('DEBUG: Failed to update backend location: $e');
    }
  }

  void addReminder(CareReminder reminder) async {
    try {
      await _elderRepository.addReminder({
        'title': reminder.title,
        'subtitle': reminder.subtitle,
        'icon_name': 'notifications_active_outlined',
      });
      loadDashboard(); // Refresh from server
    } catch (e) {
      debugPrint('Error adding reminder: $e');
    }
  }

  void updateReminder(CareReminder reminder) {
    // ... existing local logic or implement PUT backend ...
  }

  void deleteReminder(String reminderId) {
    // ... existing local logic or implement DELETE backend ...
  }

  void addAppointment(Appointment appointment) async {
    try {
      await _elderRepository.addAppointment({
        'doctor_name': appointment.doctorName,
        'specialty': appointment.specialty,
        'appointment_date': appointment.date,
        'appointment_time': appointment.time,
        'location': appointment.location,
      });
      loadDashboard(); // Refresh from server
    } catch (e) {
      debugPrint('Error adding appointment: $e');
    }
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

  // Temporary mock data for reminders/appointments until those APIs are ready
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
}
