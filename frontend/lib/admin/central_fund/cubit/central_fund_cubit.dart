import 'package:flutter_bloc/flutter_bloc.dart';
import 'central_fund_state.dart';

class CentralFundCubit extends Cubit<CentralFundState> {
  CentralFundCubit() : super(const CentralFundInitial());

  void changeTab(int index) {
    emit(CentralFundLoaded(selectedTabIndex: index));
  }
}