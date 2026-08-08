import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/shared/medicine/models/medicine.dart';
import 'package:frontend/shared/reminders/models/appointment.dart';
import 'package:frontend/shared/reminders/models/care_reminder.dart';

import '../data/patient_details_dummy_data.dart';

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

  /// Loads the patient's vitals, medications, and reminders.
  /// TODO: replace with a real repository call keyed by [PatientDetailsState.patientId].
  void loadCarePlan() {
    final now = DateTime.now();
    final basicInfo = PatientDetailsDummyData.basicInfo();
    emit(
      state.copyWith(
        bpCheckedAt: now.subtract(const Duration(hours: 2)),
        heartRateCheckedAt: now.subtract(const Duration(minutes: 15)),
        medications: PatientDetailsDummyData.medications(),
        otherReminders: PatientDetailsDummyData.otherReminders(),
        appointments: PatientDetailsDummyData.appointments(),
        gender: basicInfo.gender,
        dateOfBirth: basicInfo.dateOfBirth,
        phone: basicInfo.phone,
        email: basicInfo.email,
        address: basicInfo.address,
        healthCondition: basicInfo.healthCondition,
      ),
    );
  }

  void markMedicationTaken(String medicationId) {
    final updated = state.medications.map((medicine) {
      if (medicine.id != medicationId) return medicine;
      return medicine.copyWith(isTakenToday: true);
    }).toList();
    emit(state.copyWith(medications: updated));
  }

  void logBloodPressure({required int systolic, required int diastolic}) {
    // TODO: send the new reading to the backend.
    emit(
      state.copyWith(
        bpSystolic: systolic,
        bpDiastolic: diastolic,
        bpCheckedAt: DateTime.now(),
      ),
    );
  }

  void logHeartRate(int bpm) {
    // TODO: send the new reading to the backend.
    final updatedRecent = [...state.heartRateRecent.skip(1), bpm];
    emit(
      state.copyWith(
        heartRateBpm: bpm,
        heartRateCheckedAt: DateTime.now(),
        heartRateRecent: updatedRecent,
      ),
    );
  }

  // ---- Reminder editing (Add / Modify / Delete) ----
  // TODO: sync these changes to a real backend once the care-plan API exists.

  void addMedication(Medicine medicine) {
    emit(state.copyWith(medications: [...state.medications, medicine]));
  }

  void updateMedication(Medicine updatedMedicine) {
    final updated = state.medications
        .map((m) => m.id == updatedMedicine.id ? updatedMedicine : m)
        .toList();
    emit(state.copyWith(medications: updated));
  }

  void deleteMedication(String medicationId) {
    final updated =
    state.medications.where((m) => m.id != medicationId).toList();
    emit(state.copyWith(medications: updated));
  }

  void addCareReminder(CareReminder reminder) {
    emit(state.copyWith(otherReminders: [...state.otherReminders, reminder]));
  }

  void updateCareReminder(CareReminder updatedReminder) {
    final updated = state.otherReminders
        .map((r) => r.id == updatedReminder.id ? updatedReminder : r)
        .toList();
    emit(state.copyWith(otherReminders: updated));
  }

  void deleteCareReminder(String reminderId) {
    final updated =
    state.otherReminders.where((r) => r.id != reminderId).toList();
    emit(state.copyWith(otherReminders: updated));
  }

  void addAppointment(Appointment appointment) {
    emit(state.copyWith(appointments: [...state.appointments, appointment]));
  }

  void updateAppointment(Appointment updatedAppointment) {
    final updated = state.appointments
        .map((a) => a.id == updatedAppointment.id ? updatedAppointment : a)
        .toList();
    emit(state.copyWith(appointments: updated));
  }

  void deleteAppointment(String appointmentId) {
    final updated =
    state.appointments.where((a) => a.id != appointmentId).toList();
    emit(state.copyWith(appointments: updated));
  }
}
