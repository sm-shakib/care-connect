import 'package:equatable/equatable.dart';

enum CentralFundStatus { initial, loading, success, failure }

class CentralFundState extends Equatable {
  const CentralFundState({
    this.status = CentralFundStatus.initial,
    this.selectedTabIndex = 0,
    this.totalAmount = 0.0,
    this.donationCount = 0,
    this.donations = const [],
    this.errorMessage,
  });

  final CentralFundStatus status;
  final int selectedTabIndex;
  final double totalAmount;
  final int donationCount;
  final List<Map<String, dynamic>> donations;
  final String? errorMessage;

  CentralFundState copyWith({
    CentralFundStatus? status,
    int? selectedTabIndex,
    double? totalAmount,
    int? donationCount,
    List<Map<String, dynamic>>? donations,
    String? errorMessage,
  }) {
    return CentralFundState(
      status: status ?? this.status,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      totalAmount: totalAmount ?? this.totalAmount,
      donationCount: donationCount ?? this.donationCount,
      donations: donations ?? this.donations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedTabIndex,
        totalAmount,
        donationCount,
        donations,
        errorMessage,
      ];
}
