import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/caregiver_earnings_dummy_data.dart';
import 'caregiver_earnings_state.dart';

class CaregiverEarningsCubit extends Cubit<CaregiverEarningsState> {
  CaregiverEarningsCubit() : super(const CaregiverEarningsState()) {
    _loadEarnings();
  }

  void _loadEarnings() {
    emit(state.copyWith(isLoading: true));
    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      emit(state.copyWith(
        earnings: CaregiverEarningsDummyData.earnings,
        isLoading: false,
      ));
    });
  }
}
