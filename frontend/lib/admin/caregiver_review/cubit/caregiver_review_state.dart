import 'package:equatable/equatable.dart';

import 'caregiver_application_model.dart';

enum CaregiverReviewStatus { initial, loading, success, failure }

/// The outcome of a decision action (approve / request docs / reject),
/// so the view can show a snackbar/dialog once and then reset.
enum CaregiverReviewDecision { none, approved, docsRequested, rejected }

enum CaregiverReviewSubmitStatus { idle, submitting, submitted }

const int kAdminNotesMaxLength = 200;

class CaregiverReviewState extends Equatable {
  const CaregiverReviewState({
    this.status = CaregiverReviewStatus.initial,
    this.application,
    this.errorMessage,
    this.adminNotes = '',
    this.submitStatus = CaregiverReviewSubmitStatus.idle,
    this.decision = CaregiverReviewDecision.none,
  });

  final CaregiverReviewStatus status;
  final CaregiverApplication? application;
  final String? errorMessage;
  final String adminNotes;
  final CaregiverReviewSubmitStatus submitStatus;
  final CaregiverReviewDecision decision;

  bool get isLoading => status == CaregiverReviewStatus.loading;
  bool get isSubmitting =>
      submitStatus == CaregiverReviewSubmitStatus.submitting;
  bool get notesOverLimit => adminNotes.length > kAdminNotesMaxLength;

  CaregiverReviewState copyWith({
    CaregiverReviewStatus? status,
    CaregiverApplication? application,
    String? errorMessage,
    String? adminNotes,
    CaregiverReviewSubmitStatus? submitStatus,
    CaregiverReviewDecision? decision,
  }) {
    return CaregiverReviewState(
      status: status ?? this.status,
      application: application ?? this.application,
      errorMessage: errorMessage,
      adminNotes: adminNotes ?? this.adminNotes,
      submitStatus: submitStatus ?? this.submitStatus,
      decision: decision ?? this.decision,
    );
  }

  @override
  List<Object?> get props => [
    status,
    application,
    errorMessage,
    adminNotes,
    submitStatus,
    decision,
  ];
}