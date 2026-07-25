import 'package:equatable/equatable.dart';

import '../models/medicine.dart';

enum MedicineStatus { initial, loading, success, failure }

class MedicineState extends Equatable {
  const MedicineState({
    this.status = MedicineStatus.initial,
    this.medicines = const <Medicine>[],
    this.errorMessage,
  });

  final MedicineStatus status;
  final List<Medicine> medicines;
  final String? errorMessage;

  bool get isLoading =>
      status == MedicineStatus.loading || status == MedicineStatus.initial;

  MedicineState copyWith({
    MedicineStatus? status,
    List<Medicine>? medicines,
    String? errorMessage,
  }) {
    return MedicineState(
      status: status ?? this.status,
      medicines: medicines ?? this.medicines,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, medicines, errorMessage];
}
