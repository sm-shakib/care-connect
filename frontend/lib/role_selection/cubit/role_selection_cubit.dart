import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'role_selection_state.dart';

class RoleSelectionCubit extends Cubit<RoleSelectionState> {
  RoleSelectionCubit() : super(const RoleSelectionState());

  /// Called when the user taps one of the three role cards.
  void selectRole(UserRole role) {
    emit(state.copyWith(selectedRole: role));
  }

  /// Called when the user taps "Continue".
  /// Returns the chosen role so the caller (e.g. the page/navigator)
  /// can decide where to go next.
  UserRole? confirmSelection() {
    return state.selectedRole;
  }
}