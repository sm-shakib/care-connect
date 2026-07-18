import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_models.dart';
import 'dashboard_state.dart';


class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      // TODO(careconnect): replace with repository call to FastAPI backend.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          userName: 'Adib',
          medications: _mockMedications,
          caregiver: _mockCaregiver,
          chatPreview: _mockChatPreview,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: 'Unable to load your dashboard. Please try again.',
        ),
      );
    }
  }


  void markMedicationTaken(String medicationId) {
    final updated = state.medications.map((medication) {
      if (medication.id != medicationId) return medication;
      return medication.copyWith(isTaken: true);
    }).toList();
    emit(state.copyWith(medications: updated));
  }

  static const _mockMedications = [
    Medication(
      id: 'M-1',
      name: 'Metformin',
      dosage: '500mg, 1 tablet',
      time: '8:00 AM',
      isTaken: true,
    ),
    Medication(
      id: 'M-2',
      name: 'Lisinopril',
      dosage: '10mg, 1 tablet',
      time: '1:00 PM',
    ),
    Medication(
      id: 'M-3',
      name: 'Atorvastatin',
      dosage: '20mg, 1 tablet',
      time: '9:00 PM',
    ),
  ];

  static const _mockCaregiver = CaregiverSummary(
    id: 'C-1',
    name: 'Shakib Khan',
    profession: 'Registered Nurse',
    nextVisitLabel: 'Today, 3:00 PM',
    phone: '+1 555-0134',
  );

  static const _mockChatPreview = ChatPreview(
    senderName: 'Lamine Yamal',
    lastMessage: "Don't forget your afternoon walk today!",
    timeLabel: '10 min ago',
    unreadCount: 2,
  );
}
