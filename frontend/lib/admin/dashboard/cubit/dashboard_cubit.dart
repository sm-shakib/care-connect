import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_model.dart';
import 'dashboard_state.dart';

/// Loads the dashboard's summary counts (SOS alerts, pending
/// verifications, open complaints) and recent activity feed.
///
/// NOTE: everything here is mock data. Replace [loadDashboard] with
/// repository calls into your FastAPI backend — ideally aggregating
/// counts from the same data sources `caregiver_verification` and
/// `complaint_management` already use, so the numbers shown here stay
/// in sync with those screens instead of drifting as separate mocks.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      // TODO(careconnect): replace with repository calls to FastAPI
      // backend (SOS alert count, pending verification count, open
      // complaint count, recent activity feed).
      await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          sosAlertCount: 3,
          pendingVerificationCount: 24,
          openComplaintCount: 12,
          activities: _mockActivities,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: 'Unable to load the dashboard. Please try again.',
        ),
      );
    }
  }

  static const List<ActivityItem> _mockActivities = [
    ActivityItem(
      id: 'act-1',
      type: ActivityType.caregiver,
      title: 'Caregiver Application',
      // Matches the "Adib Khan" pending entry in caregiver_verification's
      // mock data, so tapping through tells a consistent story.
      subtitle: 'Adib Khan submitted docs',
      timeAgo: '2m ago',
    ),
    ActivityItem(
      id: 'act-2',
      type: ActivityType.complaint,
      title: 'New Complaint #CP-1024',
      // Matches complaint_management's CP-1024 mock entry.
      subtitle: 'Filed by Abdur Rahim against Nasrin Akter',
      timeAgo: '15m ago',
    ),
    /*ActivityItem(
      id: 'act-3',
      type: ActivityType.booking,
      title: 'Booking Conflict',
      subtitle: 'Overlapping shifts detected in Zone B',
      timeAgo: '1h ago',
    ),*/
  ];
}