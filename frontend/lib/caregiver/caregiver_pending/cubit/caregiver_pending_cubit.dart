import 'package:flutter_bloc/flutter_bloc.dart';

part 'caregiver_pending_state.dart';

class CaregiverPendingCubit extends Cubit<CaregiverPendingState> {
  CaregiverPendingCubit() : super(const CaregiverPendingState());

  void refreshStatus() {
    // Later this will check whether the admin has verified the caregiver.
    emit(state);
  }
}