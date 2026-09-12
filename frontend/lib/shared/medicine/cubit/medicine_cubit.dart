import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../alarm/medicine_alarm_service.dart';
import '../data/medicine_repository.dart';
import '../models/medicine.dart';
import 'medicine_state.dart';

/// Manages the elder's medicine list against the backend. This is the only
/// place medicine alarms get scheduled — see [MedicineAlarmService] — and
/// since [MedicineCubit] is only ever constructed for the elderly role,
/// alarms are inherently elder-only too.
class MedicineCubit extends Cubit<MedicineState> {
  MedicineCubit(this._repository, {this.elderId}) : super(const MedicineState()) {
    // A dose can be marked taken from the alarm screen, which updates the
    // backend directly without any reference to this cubit (see
    // MedicineAlarmPage) — reload whenever that happens so this doesn't
    // keep showing stale data.
    _alarmSubscription =
        MedicineAlarmService.instance.onMedicineUpdated.listen((_) {
      loadMedicines();
    });
  }

  final MedicineRepository _repository;
  final int? elderId;
  late final StreamSubscription<void> _alarmSubscription;

  @override
  Future<void> close() {
    _alarmSubscription.cancel();
    return super.close();
  }

  Future<void> loadMedicines() async {
    debugPrint('DEBUG: MedicineCubit.loadMedicines(elderId: $elderId) called');
    
    emit(state.copyWith(status: MedicineStatus.loading));
    try {
      final medicines = await _repository.getMedicines(elderId: elderId);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: MedicineStatus.success,
            medicines: medicines,
          ),
        );
        unawaited(MedicineAlarmService.instance.syncSchedule(medicines));
      }
    } catch (e) {
      debugPrint('MedicineCubit.loadMedicines error: $e');
      if (!isClosed) {
        emit(
          state.copyWith(
            status: MedicineStatus.failure,
            errorMessage: 'Unable to load medicines. Please try again.',
          ),
        );
      }
    }
  }

  Future<void> addMedicine(Medicine medicine) async {
    try {
      final created = await _repository.createMedicine(medicine, elderId: elderId);
      // Replace the temporary item (if any) with the real one from server.
      // We identify it by name since newly added ones don't have real IDs yet.
      final medicines = state.medicines
          .where((m) => !m.id.startsWith('MED-') || m.name != medicine.name)
          .toList();
      
      final updatedMedicines = [...medicines, created];
      emit(state.copyWith(medicines: updatedMedicines));
      unawaited(MedicineAlarmService.instance.syncSchedule(updatedMedicines));
    } catch (e) {
      debugPrint('MedicineCubit.addMedicine error: $e');
    }
  }

  Future<void> updateMedicine(Medicine medicine) async {
    try {
      final updated = await _repository.updateMedicine(medicine);
      final medicines = state.medicines
          .map((existing) => existing.id == updated.id ? updated : existing)
          .toList();
      emit(state.copyWith(medicines: medicines));
      unawaited(MedicineAlarmService.instance.syncSchedule(medicines));
    } catch (e) {
      debugPrint('MedicineCubit.updateMedicine error: $e');
    }
  }

  Future<void> deleteMedicine(String medicineId) async {
    // Optimistic update: remove from UI immediately
    final previousMedicines = state.medicines;
    final updatedMedicines =
        state.medicines.where((m) => m.id != medicineId).toList();
    emit(state.copyWith(medicines: updatedMedicines));

    try {
      // Don't try to delete unsaved medicines from backend
      if (!medicineId.startsWith('MED-')) {
        await _repository.deleteMedicine(medicineId);
      }
      unawaited(MedicineAlarmService.instance.syncSchedule(updatedMedicines));
    } catch (e) {
      debugPrint('MedicineCubit.deleteMedicine error: $e');
      // Rollback on failure
      if (!isClosed) {
        emit(state.copyWith(medicines: previousMedicines));
      }
    }
  }

  Future<void> markTaken(String medicineId, String time) async {
    try {
      final updated = await _repository.markTaken(medicineId, time);
      final medicines = state.medicines
          .map((medicine) => medicine.id == updated.id ? updated : medicine)
          .toList();
      emit(state.copyWith(medicines: medicines));
    } catch (e) {
      debugPrint('MedicineCubit.markTaken error: $e');
    }
  }
}
