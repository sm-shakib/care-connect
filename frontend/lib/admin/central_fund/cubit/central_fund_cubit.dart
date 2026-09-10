import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/central_fund_repository.dart';
import 'central_fund_state.dart';

class CentralFundCubit extends Cubit<CentralFundState> {
  final CentralFundRepository _repository;

  CentralFundCubit(this._repository) : super(const CentralFundInitial());

  Future<void> loadData() async {
    emit(CentralFundLoading(selectedTabIndex: state.selectedTabIndex));
    try {
      final stats = await _repository.getFundStats();
      final donations = await _repository.getDonations();
      final requests = await _repository.getAidRequests();
      
      emit(CentralFundLoaded(
        selectedTabIndex: state.selectedTabIndex,
        stats: stats,
        donations: donations,
        requests: requests,
      ));
    } catch (e) {
      emit(CentralFundError(e.toString(), selectedTabIndex: state.selectedTabIndex));
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
