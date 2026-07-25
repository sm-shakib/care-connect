import 'package:equatable/equatable.dart';

import 'elderly_profile_model.dart';

enum ElderlyDetailLoadStatus { initial, loading, success, failure }

/// One-shot outcome flags so the view can react (snackbar) then reset.
enum ElderlyDetailAction { none, statusChanged, removed }

class ElderlyDetailState extends Equatable {
  const ElderlyDetailState({
    this.loadStatus = ElderlyDetailLoadStatus.initial,
    this.profile,
    this.errorMessage,
    this.action = ElderlyDetailAction.none,
  });

  final ElderlyDetailLoadStatus loadStatus;
  final ElderlyProfile? profile;
  final String? errorMessage;
  final ElderlyDetailAction action;

  bool get isLoading => loadStatus == ElderlyDetailLoadStatus.loading;
  bool get isSuspended => profile?.status == AccountStatus.suspended;

  ElderlyDetailState copyWith({
    ElderlyDetailLoadStatus? loadStatus,
    ElderlyProfile? profile,
    String? errorMessage,
    ElderlyDetailAction? action,
  }) {
    return ElderlyDetailState(
      loadStatus: loadStatus ?? this.loadStatus,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [loadStatus, profile, errorMessage, action];
}