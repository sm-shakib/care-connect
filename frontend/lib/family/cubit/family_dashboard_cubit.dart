import 'package:bloc/bloc.dart';

import '../data/elder_dummy_data.dart';
import '../models/elder.dart';
import 'family_dashboard_state.dart';

class FamilyDashboardCubit extends Cubit<FamilyDashboardState> {
  FamilyDashboardCubit() : super(const FamilyDashboardState()) {
    loadElders();
  }

  /// Load all elders
  void loadElders() {
    emit(
      state.copyWith(
        elders: elderList,
        filteredElders: elderList,
      ),
    );
  }

  /// Select an elder (pass null to go back to dashboard)
  void selectElder(Elder? elder) {
    emit(
      state.copyWith(
        selectedElder: elder,
      ),
    );
  }

  /// Start booking process for a specific elder
  void startBookingForElder(Elder elder) {
    emit(
      state.copyWith(
        bookingForElder: elder,
      ),
    );
  }

  /// Clear the booking context
  void clearBookingContext() {
    emit(
      state.copyWith(
        bookingForElder: null,
      ),
    );
  }
}
