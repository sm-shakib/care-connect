import 'package:equatable/equatable.dart';
import '../../models/earnings_record.dart';

class CaregiverEarningsState extends Equatable {
  const CaregiverEarningsState({
    this.earnings = const [],
    this.isLoading = false,
  });

  final List<EarningsRecord> earnings;
  final bool isLoading;

  double get totalEarnings => earnings.fold(0, (sum, e) => sum + e.amount);

  CaregiverEarningsState copyWith({
    List<EarningsRecord>? earnings,
    bool? isLoading,
  }) {
    return CaregiverEarningsState(
      earnings: earnings ?? this.earnings,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [earnings, isLoading];
}
