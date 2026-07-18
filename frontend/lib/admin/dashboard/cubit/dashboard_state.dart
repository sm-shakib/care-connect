import 'package:equatable/equatable.dart';

import 'dashboard_model.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.sosAlertCount = 0,
    this.pendingVerificationCount = 0,
    this.openComplaintCount = 0,
    this.activities = const <ActivityItem>[],
    this.errorMessage,
  });

  final DashboardStatus status;
  final int sosAlertCount;
  final int pendingVerificationCount;
  final int openComplaintCount;
  final List<ActivityItem> activities;
  final String? errorMessage;

  bool get isLoading => status == DashboardStatus.loading;

  DashboardState copyWith({
    DashboardStatus? status,
    int? sosAlertCount,
    int? pendingVerificationCount,
    int? openComplaintCount,
    List<ActivityItem>? activities,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      sosAlertCount: sosAlertCount ?? this.sosAlertCount,
      pendingVerificationCount:
      pendingVerificationCount ?? this.pendingVerificationCount,
      openComplaintCount: openComplaintCount ?? this.openComplaintCount,
      activities: activities ?? this.activities,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    sosAlertCount,
    pendingVerificationCount,
    openComplaintCount,
    activities,
    errorMessage,
  ];
}