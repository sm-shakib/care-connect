import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:frontend/caregiver/data/repositories/booking_repository.dart';
import 'package:frontend/caregiver/models/booking_request.dart';
import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/elderly/data/repositories/elder_repository.dart';
import 'package:frontend/shared/medicine/data/medicine_repository.dart';
import 'package:frontend/shared/medicine/models/medicine.dart';
import 'package:frontend/shared/reminders/models/appointment.dart';
import 'package:frontend/shared/reminders/models/care_reminder.dart';

part 'patient_details_state.dart';

class PatientDetailsCubit extends Cubit<PatientDetailsState> {
  PatientDetailsCubit({
    required String patientId,
    required String patientName,
  }) : super(
    PatientDetailsState(
      patientId: patientId,
      patientName: patientName,
    ),
  ) {
    loadCarePlan();
  }

  final _elderRepository = ElderRepository(ApiClient());
  final _medicineRepository = MedicineRepository(ApiClient());
  final _bookingRepository = BookingRepository();
  final _authRepository = AuthRepository();

  /// Loads the patient's vitals, medications, and reminders.
  Future<void> loadCarePlan() async {
    final int? elderId = int.tryParse(state.patientId);
    if (elderId == null) return;

    emit(state.copyWith(status: PatientDetailsStatus.loading));

    try {
      final caregiverId = await _authRepository.getProfileId();
      
      final results = await Future.wait([
        _elderRepository.getElderProfile(elderId),
        _elderRepository.getAppointments(elderId: elderId),
        _elderRepository.getReminders(elderId: elderId),
        _medicineRepository.getMedicines(elderId: elderId),
        if (caregiverId != null)
          _bookingRepository.getCaregiverBookings(caregiverId)
        else
          Future.value(<BookingRequest>[]),
      ]);

      final profile = results[0] as Map<String, dynamic>;
      final appointmentsData = results[1] as List<Map<String, dynamic>>;
      final remindersData = results[2] as List<Map<String, dynamic>>;
      final medications = results[3] as List<Medicine>;
      final bookings = results[4] as List<BookingRequest>;

      // Find the specific booking for this elder
      BookingRequest? activeBooking;
      try {
        activeBooking = bookings.firstWhere(
          (b) => b.elderId == elderId && b.status == BookingStatus.accepted,
        );
      } catch (_) {
        activeBooking = null;
      }

      final appointments = appointmentsData
          .map((a) => Appointment(
                id: a['id'].toString(),
                doctorName: (a['doctor_name'] ?? '') as String,
                specialty: a['specialty'] as String? ?? '',
                date: (a['appointment_date'] ?? '') as String,
                time: (a['appointment_time'] ?? '') as String,
                location: a['location'] as String? ?? '',
              ))
          .toList();

      final reminders = remindersData.map((r) {
        final iconName = r['icon_name'] as String? ?? 'notifications';
        return CareReminder(
          id: r['id'].toString(),
          title: (r['title'] ?? '') as String,
          subtitle: r['subtitle'] as String? ?? '',
          icon: CareReminder.mapIconNameToData(iconName),
        );
      }).toList();

      final dobStr = profile['date_of_birth'] as String?;
      final dob = dobStr != null ? DateTime.tryParse(dobStr) : null;
      final genderStr = profile['gender'] as String? ?? 'Female';

      emit(
        state.copyWith(
          status: PatientDetailsStatus.success,
          bpSystolic: profile['systolic_bp'] as int? ?? 120,
          bpDiastolic: profile['diastolic_bp'] as int? ?? 80,
          heartRateBpm: profile['heart_rate'] as int? ?? 75,
          bpCheckedAt: DateTime.now(),
          heartRateCheckedAt: DateTime.now(),
          medications: medications,
          otherReminders: reminders,
          appointments: appointments,
          gender:
              genderStr.toLowerCase() == 'male' ? Gender.male : Gender.female,
          dateOfBirth: dob ?? DateTime(1950),
          phone: profile['phone'] as String? ?? '',
          email: profile['email'] as String? ?? '',
          address: profile['address'] as String? ?? '',
          healthCondition: profile['health_condition'] as String? ?? 'Stable',
          imageUrl: profile['profile_image_url'] as String? ?? '',
          serviceStartDate: activeBooking?.startDate,
          serviceEndDate: activeBooking?.endDate,
          daysOfWeek: activeBooking?.workingDaysLabel ?? '',
          dailyTimingStart: activeBooking?.startTime != null 
              ? DateFormat.jm().format(DateTime(2024, 1, 1, activeBooking!.startTime.hour, activeBooking.startTime.minute))
              : '',
          dailyTimingEnd: activeBooking?.endTime != null
              ? DateFormat.jm().format(DateTime(2024, 1, 1, activeBooking!.endTime.hour, activeBooking.endTime.minute))
              : '',
        ),
      );
    } catch (e) {
      debugPrint('Error loading patient care plan: $e');
      emit(state.copyWith(
        status: PatientDetailsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void markMedicationTaken(String medicationId, String time) async {
    try {
      await _medicineRepository.markTaken(medicationId, time);
      // Refresh to get updated state from server
      await loadCarePlan();
    } catch (e) {
      debugPrint('Error marking medication taken: $e');
    }
  }

  void logBloodPressure({required int systolic, required int diastolic}) async {
    try {
      await _elderRepository.updateElderVitals(
        elderId: state.patientId,
        heartRate: state.heartRateBpm,
        systolic: systolic,
        diastolic: diastolic,
      );
      emit(
        state.copyWith(
          bpSystolic: systolic,
          bpDiastolic: diastolic,
          bpCheckedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('Error logging BP: $e');
    }
  }

  void logHeartRate(int bpm) async {
    try {
      await _elderRepository.updateElderVitals(
        elderId: state.patientId,
        heartRate: bpm,
        systolic: state.bpSystolic,
        diastolic: state.bpDiastolic,
      );
      final updatedRecent = [...state.heartRateRecent.skip(1), bpm];
      emit(
        state.copyWith(
          heartRateBpm: bpm,
          heartRateCheckedAt: DateTime.now(),
          heartRateRecent: updatedRecent,
        ),
      );
    } catch (e) {
      debugPrint('Error logging heart rate: $e');
    }
  }

  // ---- Reminder editing (Add / Modify / Delete) ----

  void addMedication(Medicine medicine) async {
    final int? elderId = int.tryParse(state.patientId);
    if (elderId == null) return;
    try {
      // Optimistic update
      final previous = state.medications;
      emit(state.copyWith(medications: [...previous, medicine]));

      await _medicineRepository.createMedicine(medicine, elderId: elderId);
      await loadCarePlan();
    } catch (e) {
      debugPrint('Error adding medication: $e');
      await loadCarePlan();
    }
  }

  void updateMedication(Medicine updatedMedicine) async {
    try {
      await _medicineRepository.updateMedicine(updatedMedicine);
      await loadCarePlan();
    } catch (e) {
      debugPrint('Error updating medication: $e');
    }
  }

  void deleteMedication(String medicationId) async {
    // Optimistic update
    final previousMedicines = state.medications;
    final updatedMedicines =
        state.medications.where((m) => m.id != medicationId).toList();
    emit(state.copyWith(medications: updatedMedicines));

    try {
      if (!medicationId.startsWith('MED-')) {
        await _medicineRepository.deleteMedicine(medicationId);
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await loadCarePlan();
    } catch (e) {
      debugPrint('Error deleting medication: $e');
      // Rollback
      emit(state.copyWith(medications: previousMedicines));
    }
  }

  void addCareReminder(CareReminder reminder) async {
    final int? elderId = int.tryParse(state.patientId);
    if (elderId == null) return;
    try {
      await _elderRepository.addReminder({
        'title': reminder.title,
        'subtitle': reminder.subtitle,
        'icon_name': CareReminder.mapIconDataToName(reminder.icon),
      }, elderId: elderId);
      await loadCarePlan();
    } catch (e) {
      debugPrint('Error adding reminder: $e');
    }
  }

  void updateCareReminder(CareReminder updatedReminder) async {
    final int? reminderId = int.tryParse(updatedReminder.id);
    if (reminderId == null) return;
    try {
      await _elderRepository.updateReminder(reminderId, {
        'title': updatedReminder.title,
        'subtitle': updatedReminder.subtitle,
        'icon_name': CareReminder.mapIconDataToName(updatedReminder.icon),
      });
      await loadCarePlan();
    } catch (e) {
      debugPrint('Error updating reminder: $e');
    }
  }

  void deleteCareReminder(String reminderId) async {
    final int? id = int.tryParse(reminderId);
    if (id == null) return;

    // Optimistic update
    final previousReminders = state.otherReminders;
    final updatedReminders =
        state.otherReminders.where((r) => r.id != reminderId).toList();
    emit(state.copyWith(otherReminders: updatedReminders));

    try {
      await _elderRepository.deleteReminder(id);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await loadCarePlan();
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      // Rollback
      emit(state.copyWith(otherReminders: previousReminders));
    }
  }

  void addAppointment(Appointment appointment) async {
    final int? elderId = int.tryParse(state.patientId);
    if (elderId == null) return;
    try {
      await _elderRepository.addAppointment({
        'doctor_name': appointment.doctorName,
        'specialty': appointment.specialty,
        'appointment_date': appointment.date,
        'appointment_time': appointment.time,
        'location': appointment.location,
      }, elderId: elderId);
      await loadCarePlan();
    } catch (e) {
      debugPrint('Error adding appointment: $e');
    }
  }

  void updateAppointment(Appointment updatedAppointment) async {
    final int? appointmentId = int.tryParse(updatedAppointment.id);
    if (appointmentId == null) return;
    try {
      await _elderRepository.updateAppointment(appointmentId, {
        'doctor_name': updatedAppointment.doctorName,
        'specialty': updatedAppointment.specialty,
        'appointment_date': updatedAppointment.date,
        'appointment_time': updatedAppointment.time,
        'location': updatedAppointment.location,
      });
      await loadCarePlan();
    } catch (e) {
      debugPrint('Error updating appointment: $e');
    }
  }

  void deleteAppointment(String appointmentId) async {
    final int? id = int.tryParse(appointmentId);
    if (id == null) return;

    // Optimistic update
    final previousAppointments = state.appointments;
    final updatedAppointments =
        state.appointments.where((a) => a.id != appointmentId).toList();
    emit(state.copyWith(appointments: updatedAppointments));

    try {
      await _elderRepository.deleteAppointment(id);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await loadCarePlan();
    } catch (e) {
      debugPrint('Error deleting appointment: $e');
      // Rollback
      emit(state.copyWith(appointments: previousAppointments));
    }
  }
}
