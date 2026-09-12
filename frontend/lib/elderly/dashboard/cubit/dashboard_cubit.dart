import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver/data/repositories/booking_repository.dart';
import 'package:frontend/caregiver/models/booking_request.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/core/services/location_service.dart';
import 'package:frontend/elderly/dashboard/cubit/dashboard_models.dart';
import 'package:frontend/elderly/dashboard/cubit/dashboard_state.dart';
import 'package:frontend/elderly/data/repositories/elder_repository.dart';
import 'package:frontend/family/data/repositories/binding_repository.dart';
import 'package:frontend/family/models/binding_request.dart';
import 'package:frontend/shared/reminders/models/appointment.dart';
import 'package:frontend/shared/reminders/models/care_reminder.dart';
import 'package:geolocator/geolocator.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._bindingRepository) : super(const DashboardState());

  final BindingRepository _bindingRepository;
  final _bookingRepository = BookingRepository();
  final _authRepository = AuthRepository();
  final _elderRepository = ElderRepository(ApiClient());
  final _locationService = LocationService();
  StreamSubscription<Position>? _locationSubscription;
  Timer? _vitalsTimer;

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    _vitalsTimer?.cancel();
    return super.close();
  }

  Future<void> loadDashboardWithAuth(AuthRepository authRepository) async {
    await loadDashboard();
  }

  Future<void> loadDashboard() async {
    log('DEBUG: loadDashboard called');
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final profileId = await _authRepository.getProfileId();

      final results = await Future.wait([
        _bindingRepository.getPendingRequests(),
        _bindingRepository.getLinkedFamilyMembers(),
        _elderRepository.getMyProfile(),
        _elderRepository.getAppointments(),
        _elderRepository.getReminders(),
        if (profileId != null)
          _bookingRepository.getElderBookings(profileId)
        else
          Future.value(<BookingRequest>[]),
      ]);

      final requests = results[0] as List<BindingRequest>;
      final familyMembers = results[1] as List<Map<String, dynamic>>;
      final profile = results[2] as Map<String, dynamic>;
      final appointmentsData = results[3] as List<Map<String, dynamic>>;
      final remindersData = results[4] as List<Map<String, dynamic>>;
      final bookings = results[5] as List<BookingRequest>;

      final appointments = appointmentsData
          .map((a) => Appointment(
                id: a['id'].toString(),
                doctorName: a['doctor_name']?.toString() ?? '',
                specialty: a['specialty']?.toString() ?? '',
                date: a['appointment_date']?.toString() ?? '',
                time: a['appointment_time']?.toString() ?? '',
                location: a['location']?.toString() ?? '',
              ))
          .toList();

      final reminders = remindersData.map((r) {
        final iconName = r['icon_name']?.toString() ?? 'notifications';
        return CareReminder(
          id: r['id'].toString(),
          title: r['title']?.toString() ?? '',
          subtitle: r['subtitle']?.toString() ?? '',
          icon: CareReminder.mapIconNameToData(iconName),
        );
      }).toList();

      // Start real-time location tracking (non-blocking)
      unawaited(_startLocationTracking());

      final caregivers = <CaregiverSummary>[];
      final activeCaregiverIds = <String>[];

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final realAccepted = bookings
          .where((b) => b.status == BookingStatus.accepted && !b.endDate.isBefore(today))
          .toList();

      for (final b in realAccepted) {
        activeCaregiverIds.add(b.caregiverId.toString());
        caregivers.add(
          CaregiverSummary(
            id: b.caregiverId.toString(),
            name: b.caregiverName,
            profession: b.caregiverProfession,
            nextVisitLabel: 'Today, ${b.timingLabel.split('—')[0].trim()}',
            phone: b.caregiverPhone,
            entity: b.caregiverEntity,
            booking: b,
          ),
        );
      }

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          userName: profile['name']?.toString() ?? 'Hello',
          heartRate: profile['heart_rate'] as int? ?? 75,
          systolicBp: profile['systolic_bp'] as int? ?? 120,
          diastolicBp: profile['diastolic_bp'] as int? ?? 80,
          otherReminders: reminders,
          appointments: appointments,
          caregivers: caregivers,
          activeCaregiverIds: activeCaregiverIds,
          linkedFamilyMembers: familyMembers,
          bindingRequests: requests,
        ),
      );
    } catch (e) {
      log('DEBUG: loadDashboard error: $e');
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: 'Unable to load your dashboard: $e',
        ),
      );
    }
  }

  void _startVitalsSimulation() {
    _vitalsTimer?.cancel();
    _vitalsTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      final random = DateTime.now().second;
      unawaited(
        _elderRepository.updateVitalsAndLocation(
          heartRate: 70 + (random % 20), // 70–90
          systolicBp: 115 + (random % 10), // 115–125
          diastolicBp: 75 + (random % 10), // 75–85
        ),
      );
      debugPrint('DEBUG: Vitals updated in backend');
    });
  }

  /// Called from the UI after the user grants location permission.
  void restartLocationTracking() {
    unawaited(_startLocationTracking());
  }

  Future<void> _startLocationTracking() async {
    // Cancel existing subscription if any
    await _locationSubscription?.cancel();

    try {
      // Ensure location services are on and permission is granted
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('DEBUG: Location services are disabled');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('DEBUG: Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('DEBUG: Location permission denied forever');
        return;
      }

      // Get initial location and push to backend immediately
      final initialPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _updateBackendLocation(initialPos);

      // Subscribe to continuous updates
      _locationSubscription = _locationService.getLocationStream().listen(
        _updateBackendLocation,
        onError: (Object e) {
          debugPrint('Location tracking error: $e');
          // Retry after a delay on stream error
          Future<void>.delayed(const Duration(seconds: 30), () {
            if (!isClosed) unawaited(_startLocationTracking());
          });
        },
      );
    } catch (e) {
      debugPrint('DEBUG: Failed to start location tracking: $e');
    }
  }

  Future<void> _updateBackendLocation(Position position) async {
    try {
      await _elderRepository.updateVitalsAndLocation(
        latitude: (position.latitude as num).toDouble(),
        longitude: (position.longitude as num).toDouble(),
      );

      debugPrint(
        'DEBUG: Backend updated with location: '
        '${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      debugPrint('DEBUG: Failed to update backend location: $e');
    }
  }

  Future<void> updateVitals(int hr, int systolic, int diastolic) async {
    try {
      final profileId = await _authRepository.getProfileId();
      if (profileId != null) {
        await _elderRepository.updateElderVitals(
          elderId: profileId.toString(),
          heartRate: hr,
          systolic: systolic,
          diastolic: diastolic,
        );
        emit(state.copyWith(
          heartRate: hr,
          systolicBp: systolic,
          diastolicBp: diastolic,
        ));
      }
    } catch (e) {
      debugPrint('Error updating vitals: $e');
    }
  }

  void addReminder(CareReminder reminder) {
    unawaited(
      () async {
        try {
          await _elderRepository.addReminder({
            'title': reminder.title,
            'subtitle': reminder.subtitle,
            'icon_name': CareReminder.mapIconDataToName(reminder.icon),
          });
          await loadDashboard(); // Refresh from server
        } catch (e) {
          debugPrint('Error adding reminder: $e');
        }
      }(),
    );
  }

  void updateReminder(CareReminder reminder) {
    unawaited(
      () async {
        try {
          await _elderRepository.updateReminder(int.parse(reminder.id), {
            'title': reminder.title,
            'subtitle': reminder.subtitle,
            'icon_name': CareReminder.mapIconDataToName(reminder.icon),
          });
          await loadDashboard();
        } catch (e) {
          debugPrint('Error updating reminder: $e');
        }
      }(),
    );
  }

  void deleteReminder(String reminderId) {
    // Optimistic update
    final previousReminders = state.otherReminders;
    final updatedReminders =
        state.otherReminders.where((r) => r.id != reminderId).toList();
    emit(state.copyWith(otherReminders: updatedReminders));

    unawaited(
      () async {
        try {
          final id = int.tryParse(reminderId);
          if (id != null) {
            await _elderRepository.deleteReminder(id);
          }
          await loadDashboard();
        } catch (e) {
          debugPrint('Error deleting reminder: $e');
          if (!isClosed) {
            emit(state.copyWith(otherReminders: previousReminders));
          }
        }
      }(),
    );
  }

  void addAppointment(Appointment appointment) {
    unawaited(
      () async {
        try {
          await _elderRepository.addAppointment({
            'doctor_name': appointment.doctorName,
            'specialty': appointment.specialty,
            'appointment_date': appointment.date,
            'appointment_time': appointment.time,
            'location': appointment.location,
          });
          await loadDashboard(); // Refresh from server
        } catch (e) {
          debugPrint('Error adding appointment: $e');
        }
      }(),
    );
  }

  void updateAppointment(Appointment appointment) {
    unawaited(
      () async {
        try {
          await _elderRepository.updateAppointment(int.parse(appointment.id), {
            'doctor_name': appointment.doctorName,
            'specialty': appointment.specialty,
            'appointment_date': appointment.date,
            'appointment_time': appointment.time,
            'location': appointment.location,
          });
          await loadDashboard();
        } catch (e) {
          debugPrint('Error updating appointment: $e');
        }
      }(),
    );
  }

  void deleteAppointment(String appointmentId) {
    // Optimistic update
    final previousAppointments = state.appointments;
    final updatedAppointments =
        state.appointments.where((a) => a.id != appointmentId).toList();
    emit(state.copyWith(appointments: updatedAppointments));

    unawaited(
      () async {
        try {
          final id = int.tryParse(appointmentId);
          if (id != null) {
            await _elderRepository.deleteAppointment(id);
          }
          await loadDashboard();
        } catch (e) {
          debugPrint('Error deleting appointment: $e');
          if (!isClosed) {
            emit(state.copyWith(appointments: previousAppointments));
          }
        }
      }(),
    );
  }

  void updateRequestStatus(String requestId, BindingStatus status) {
    unawaited(
      () async {
        try {
          final bindingId = int.parse(requestId);
          await _bindingRepository.respondToRequest(bindingId, status);

          final updatedRequests =
              state.bindingRequests.where((req) => req.id != requestId).toList();
          emit(state.copyWith(bindingRequests: updatedRequests));
        } catch (e) {
          // Handle error
        }
      }(),
    );
  }
}
