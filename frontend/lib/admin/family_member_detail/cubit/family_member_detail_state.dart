import 'package:equatable/equatable.dart';

import 'family_member_profile_model.dart';

enum FamilyMemberDetailLoadStatus { initial, loading, success, failure }

/// One-shot outcome flags so the view can react (snackbar/pop) then
/// reset.
enum FamilyMemberDetailAction { none, statusChanged, removed }

class FamilyMemberDetailState extends Equatable {
  const FamilyMemberDetailState({
    this.loadStatus = FamilyMemberDetailLoadStatus.initial,
    this.profile,
    this.errorMessage,
    this.action = FamilyMemberDetailAction.none,
  });

  final FamilyMemberDetailLoadStatus loadStatus;
  final FamilyMemberProfile? profile;
  final String? errorMessage;
  final FamilyMemberDetailAction action;

  bool get isLoading => loadStatus == FamilyMemberDetailLoadStatus.loading;
  bool get isSuspended => profile?.status == AccountStatus.suspended;

  FamilyMemberDetailState copyWith({
    FamilyMemberDetailLoadStatus? loadStatus,
    FamilyMemberProfile? profile,
    String? errorMessage,
    FamilyMemberDetailAction? action,
  }) {
    return FamilyMemberDetailState(
      loadStatus: loadStatus ?? this.loadStatus,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [loadStatus, profile, errorMessage, action];
}