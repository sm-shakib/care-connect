import 'package:equatable/equatable.dart';

import 'dashboard_models.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.userName = '',
    this.medications = const <Medication>[],
    this.caregiver,
    this.chatPreview,
    this.errorMessage,
  });

  final DashboardStatus status;
  final String userName;
  final List<Medication> medications;
  final CaregiverSummary? caregiver;
  final ChatPreview? chatPreview;
  final String? errorMessage;

  bool get isLoading =>
      status == DashboardStatus.loading || status == DashboardStatus.initial;

  DashboardState copyWith({
    DashboardStatus? status,
    String? userName,
    List<Medication>? medications,
    CaregiverSummary? caregiver,
    ChatPreview? chatPreview,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      medications: medications ?? this.medications,
      caregiver: caregiver ?? this.caregiver,
      chatPreview: chatPreview ?? this.chatPreview,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userName,
    medications,
    caregiver,
    chatPreview,
    errorMessage,
  ];
}
