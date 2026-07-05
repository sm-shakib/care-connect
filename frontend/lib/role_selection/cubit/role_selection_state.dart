part of 'role_selection_cubit.dart';

/// The three roles a user can pick on the "Who are you?" screen.
enum UserRole { elderlyPerson, caregiver, familyMember }

class RoleSelectionState extends Equatable {

  const RoleSelectionState({this.selectedRole});
  final UserRole? selectedRole;

  bool get isRoleSelected => selectedRole != null;

  RoleSelectionState copyWith({UserRole? selectedRole}) {
    return RoleSelectionState(
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }

  @override
  List<Object?> get props => [selectedRole];
}