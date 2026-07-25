import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/patient_details_dummy_data.dart';
import '../models/care_reminder.dart';
import '../models/medication_reminder.dart';

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
    emit(
      state.copyWith(
        bpCheckedAt: now.subtract(const Duration(hours: 2)),
        heartRateCheckedAt: now.subtract(const Duration(minutes: 15)),
        medications: PatientDetailsDummyData.medications(),
        otherReminders: PatientDetailsDummyData.otherReminders(),
      ),
    );
  }

  void markMedicationTaken(String medicationId) {
    final updated = state.medications.map((medication) {
      if (medication.id != medicationId) return medication;
      return medication.copyWith(
        status: MedicationStatus.taken,
        takenAt: DateTime.now(),
      );
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
}