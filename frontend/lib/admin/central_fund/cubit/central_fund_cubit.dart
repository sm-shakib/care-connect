import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/central_fund_repository.dart';
import '../models/central_fund_models.dart';
import 'central_fund_state.dart';

class CentralFundCubit extends Cubit<CentralFundState> {
  final CentralFundRepository _repository;

  CentralFundCubit(this._repository) : super(const CentralFundInitial());

  Future<void> loadData() async {
    emit(CentralFundLoading(selectedTabIndex: state.selectedTabIndex));
    try {
      // Fetch in parallel
      final results = await Future.wait([
        _repository.getFundStats(),
        _repository.getDonations(),
        _repository.getAidRequests(),
      ]);
      
      emit(CentralFundLoaded(
        selectedTabIndex: state.selectedTabIndex,
        stats: results[0] as FundStats,
        donations: results[1] as List<DonationModel>,
        requests: results[2] as List<AidRequestModel>,
      ));
    } catch (e) {
      emit(CentralFundError('Failed to load fund data: $e', selectedTabIndex: state.selectedTabIndex));
    }
  }

  void changeTab(int index) {
    if (state is CentralFundLoaded) {
      final loaded = state as CentralFundLoaded;
      emit(CentralFundLoaded(
        selectedTabIndex: index,
        stats: loaded.stats,
        donations: loaded.donations,
        requests: loaded.requests,
      ));
    } else {
      emit(CentralFundInitial(selectedTabIndex: index));
    }
  }
}
