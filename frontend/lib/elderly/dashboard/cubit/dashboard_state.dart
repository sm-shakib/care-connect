import 'package:equatable/equatable.dart';
import 'package:frontend/family/models/binding_request.dart';
import 'package:frontend/shared/reminders/models/appointment.dart';
import 'package:frontend/shared/reminders/models/care_reminder.dart';

import 'dashboard_models.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.userName = '',
    this.otherReminders = const <CareReminder>[],
    this.appointments = const <Appointment>[],
    this.bindingRequests = const <BindingRequest>[],
    this.caregiver,
    this.chatPreview,
    this.errorMessage,
    this.heartRate = 75,
    this.systolicBp = 120,
    this.diastolicBp = 80,
  });

  final DashboardStatus status;
  final String userName;
  final List<CareReminder> otherReminders;
  final List<Appointment> appointments;
  final List<BindingRequest> bindingRequests;
  final CaregiverSummary? caregiver;
  final ChatPreview? chatPreview;
  final String? errorMessage;
  final int heartRate;
  final int systolicBp;
  final int diastolicBp;

  bool get isLoading =>
      status == DashboardStatus.loading || status == DashboardStatus.initial;

  DashboardState copyWith({
    DashboardStatus? status,
    String? userName,
    List<CareReminder>? otherReminders,
    List<Appointment>? appointments,
    List<BindingRequest>? bindingRequests,
    CaregiverSummary? caregiver,
    ChatPreview? chatPreview,
    String? errorMessage,
    int? heartRate,
    int? systolicBp,
    int? diastolicBp,
  }) {
    return DashboardState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      otherReminders: otherReminders ?? this.otherReminders,
      appointments: appointments ?? this.appointments,
      bindingRequests: bindingRequests ?? this.bindingRequests,
      caregiver: caregiver ?? this.caregiver,
      chatPreview: chatPreview ?? this.chatPreview,
      errorMessage: errorMessage,
      heartRate: heartRate ?? this.heartRate,
      systolicBp: systolicBp ?? this.systolicBp,
      diastolicBp: diastolicBp ?? this.diastolicBp,
    );
  }

  @override
  List<Object?> get props => [
        status,
        userName,
        otherReminders,
        appointments,
        bindingRequests,
        caregiver,
        chatPreview,
        errorMessage,
        heartRate,
        systolicBp,
        diastolicBp,
      ];
}
