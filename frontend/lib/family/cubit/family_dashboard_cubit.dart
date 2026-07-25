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

  /// Filter elders by name or relationship
  void searchElders(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(filteredElders: state.elders));
      return;
    }

    final filtered = state.elders.where((elder) {
      final nameMatch = elder.name.toLowerCase().contains(query.toLowerCase());
      final relationMatch =
          elder.relationship.toLowerCase().contains(query.toLowerCase());
      return nameMatch || relationMatch;
    }).toList();

    emit(state.copyWith(filteredElders: filtered));
  }

  /// Select an elder (pass null to go back to dashboard)
  void selectElder(Elder? elder) {
    emit(
      state.copyWith(
        selectedElder: () => elder,
      ),
    );
  }

  /// Start booking process for a specific elder
  void startBookingForElder(Elder elder) {
    emit(
      state.copyWith(
        bookingForElder: () => elder,
      ),
    );
  }

  /// Clear the booking context
  void clearBookingContext() {
    emit(
      state.copyWith(
        bookingForElder: () => null,
      ),
    );
  }

  /// Add a caregiver to a specific elder after successful booking
  void addCaregiverToElder(String elderId, String caregiverName) {
    final List<Elder> updatedElders = state.elders.map((elder) {
      if (elder.id != elderId) return elder;

      // Avoid duplicates
      if (elder.caregivers.contains(caregiverName)) return elder;

      return elder.copyWith(
        caregivers: [...elder.caregivers, caregiverName],
        hasCaregiver: true,
      );
    }).toList();

    emit(
      state.copyWith(
        elders: updatedElders,
        filteredElders: updatedElders,
        // Update selected elder if currently viewing them
        selectedElder: state.selectedElder?.id == elderId
            ? () => updatedElders.firstWhere((e) => e.id == elderId)
            : () => state.selectedElder,
      ),
    );
  }
}
