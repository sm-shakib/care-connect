import 'package:equatable/equatable.dart';

import 'complaint_detail_model.dart';

enum ComplaintDetailLoadStatus { initial, loading, success, failure }

/// The outcome of an action, so the view can react once (e.g. show a
/// snackbar) and then reset.
enum ComplaintDetailAction { none, resolved, noteAdded }

class ComplaintDetailState extends Equatable {
  const ComplaintDetailState({
    this.loadStatus = ComplaintDetailLoadStatus.initial,
    this.complaint,
    this.errorMessage,
    this.action = ComplaintDetailAction.none,
  });

  final ComplaintDetailLoadStatus loadStatus;
  final ComplaintDetail? complaint;
  final String? errorMessage;
  final ComplaintDetailAction action;

  bool get isLoading => loadStatus == ComplaintDetailLoadStatus.loading;

  bool get isResolved =>
      complaint?.status == ComplaintDetailStatus.resolved;

  ComplaintDetailState copyWith({
    ComplaintDetailLoadStatus? loadStatus,
    ComplaintDetail? complaint,
    String? errorMessage,
    ComplaintDetailAction? action,
  }) {
    return ComplaintDetailState(
      loadStatus: loadStatus ?? this.loadStatus,
      complaint: complaint ?? this.complaint,
      errorMessage: errorMessage,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    complaint,
    errorMessage,
    action,
  ];
}