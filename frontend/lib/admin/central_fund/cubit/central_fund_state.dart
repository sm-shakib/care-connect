import 'package:equatable/equatable.dart';
import '../models/central_fund_models.dart';

abstract class CentralFundState extends Equatable {
  final int selectedTabIndex;
  const CentralFundState({this.selectedTabIndex = 0});

  @override
  List<Object?> get props => [selectedTabIndex];
}

class CentralFundInitial extends CentralFundState {
  const CentralFundInitial({super.selectedTabIndex});
}

class CentralFundLoading extends CentralFundState {
  const CentralFundLoading({super.selectedTabIndex});
}

class CentralFundLoaded extends CentralFundState {
  final FundStats stats;
  final List<DonationModel> donations;
  final List<AidRequestModel> requests;

  const CentralFundLoaded({
    required super.selectedTabIndex,
    required this.stats,
    required this.donations,
    required this.requests,
  });

  @override
  List<Object?> get props => [selectedTabIndex, stats, donations, requests];
}

class CentralFundError extends CentralFundState {
  final String message;
  const CentralFundError(this.message, {super.selectedTabIndex});

  @override
  List<Object?> get props => [selectedTabIndex, message];
}
