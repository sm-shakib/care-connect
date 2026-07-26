import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/medicine.dart';
import 'medicine_state.dart';

class MedicineCubit extends Cubit<MedicineState> {
  MedicineCubit() : super(const MedicineState());

  Future<void> loadMedicines() async {
    emit(state.copyWith(status: MedicineStatus.loading));
    try {
      // TODO(careconnect): replace with repository call to FastAPI backend.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(
        state.copyWith(
          status: MedicineStatus.success,
          medicines: _mockMedicines,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: MedicineStatus.failure,
          errorMessage: 'Unable to load your medicines. Please try again.',
        ),
      );
    }
  }

  void addMedicine(Medicine medicine) {
    emit(state.copyWith(medicines: [...state.medicines, medicine]));
  }

  void updateMedicine(Medicine medicine) {
    final updated = state.medicines
        .map((existing) => existing.id == medicine.id ? medicine : existing)
        .toList();
    emit(state.copyWith(medicines: updated));
  }

  void markTaken(String medicineId) {
    final updated = state.medicines.map((medicine) {
      if (medicine.id != medicineId) return medicine;
      return medicine.copyWith(isTakenToday: true);
    }).toList();
    emit(state.copyWith(medicines: updated));
  }

  static final _mockMedicines = [
    Medicine(
      id: 'MED-1',
      name: 'Metformin',
      dosage: '1 tablet',
      form: MedicineForm.tablet,
      timesPerDay: 1,
      scheduleTimes: const ['8:00 AM'],
      startDate: DateTime.now().subtract(const Duration(days: 14)),
      refillReminderEnabled: true,
      availableUnits: 12,
      notifyThreshold: 5,
      isTakenToday: true,
    ),
    Medicine(
      id: 'MED-2',
      name: 'Lisinopril',
      dosage: '1 tablet',
      form: MedicineForm.tablet,
      timesPerDay: 1,
      scheduleTimes: const ['1:00 PM'],
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      refillReminderEnabled: true,
      availableUnits: 3,
      notifyThreshold: 5,
    ),
    Medicine(
      id: 'MED-3',
      name: 'Atorvastatin',
      dosage: '1 capsule',
      form: MedicineForm.capsule,
      timesPerDay: 1,
      scheduleTimes: const ['9:00 PM'],
      startDate: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];
}
