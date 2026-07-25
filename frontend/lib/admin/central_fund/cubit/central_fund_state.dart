import 'package:equatable/equatable.dart';

abstract class CentralFundState extends Equatable {
  final int selectedTabIndex;

  const CentralFundState({this.selectedTabIndex = 0});

  @override
  List<Object?> get props => [selectedTabIndex];
}

class CentralFundInitial extends CentralFundState {
  const CentralFundInitial({super.selectedTabIndex});
}

class CentralFundLoaded extends CentralFundState {
  const CentralFundLoaded({super.selectedTabIndex});
}