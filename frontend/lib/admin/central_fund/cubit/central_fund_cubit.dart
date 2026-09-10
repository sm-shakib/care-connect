import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/central_fund/cubit/central_fund_state.dart';
import 'package:frontend/core/donation/data/donation_repository.dart';

class CentralFundCubit extends Cubit<CentralFundState> {
  CentralFundCubit({DonationRepository? repository})
      : _repository = repository ?? DonationRepository(),
        super(const CentralFundState()) {
    unawaited(loadStats());
  }

  final DonationRepository _repository;

  Future<void> loadStats() async {
    emit(state.copyWith(status: CentralFundStatus.loading));
    try {
      final stats = await _repository.getAdminDonationStats();
      emit(state.copyWith(
        status: CentralFundStatus.success,
        totalAmount: (stats['total_amount'] as num).toDouble(),
        donationCount: stats['donation_count'] as int,
        donations: List<Map<String, dynamic>>.from(
          stats['recent_donations'] as Iterable,
        ),
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        status: CentralFundStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void changeTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }
}
