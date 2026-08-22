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
          // Since Cubits shouldn't have BuildContext, we might need to handle 
          // this in the UI or use a static error key.
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

  void deleteMedicine(String medicineId) {
    final updated =
        state.medicines.where((medicine) => medicine.id != medicineId).toList();
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
      // Old technique: name: 'Metformin (মেটফরমিন)',
      name: 'Metformin',
      nameBn: 'মেটফরমিন',
      dosage: '1',
      form: MedicineForm.tablet,
      timesPerDay: 1,
      scheduleTimes: const ['8:00 AM'],
      startDate: DateTime.now().subtract(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 16)),
      refillReminderEnabled: true,
      availableUnits: 12,
      notifyThreshold: 5,
      isTakenToday: true,
    ),
    Medicine(
      id: 'MED-2',
      // Old technique: name: 'Lisinopril (লিসিনোপ্রিল)',
      name: 'Lisinopril',
      nameBn: 'লিসিনোপ্রিল',
      dosage: '1',
      form: MedicineForm.tablet,
      timesPerDay: 1,
      scheduleTimes: const ['1:00 PM'],
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 30)),
      refillReminderEnabled: true,
      availableUnits: 3,
      notifyThreshold: 5,
    ),
    Medicine(
      id: 'MED-3',
      // Old technique: name: 'Atorvastatin (অ্যাটোরভাস্ট্যাটিন)',
      name: 'Atorvastatin',
      nameBn: 'অ্যাটোরভাস্ট্যাটিন',
      dosage: '1',
      form: MedicineForm.capsule,
      timesPerDay: 1,
      scheduleTimes: const ['9:00 PM'],
      startDate: DateTime.now().subtract(const Duration(days: 60)),
      endDate: DateTime.now().add(const Duration(days: 60)),
    ),
  ];
}
