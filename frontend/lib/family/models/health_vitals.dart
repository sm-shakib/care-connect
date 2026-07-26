import 'package:equatable/equatable.dart';

class HealthVitals extends Equatable {
  const HealthVitals({
    required this.heartRate,
    required this.heartRateStatus,
    required this.systolic,
    required this.diastolic,
    required this.bpStatus,
  });

  final int heartRate;
  final String heartRateStatus;
  final int systolic;
  final int diastolic;
  final String bpStatus;

  @override
  List<Object?> get props => [
        heartRate,
        heartRateStatus,
        systolic,
        diastolic,
        bpStatus,
      ];
}
