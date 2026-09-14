import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/repositories/admin_repository.dart';
import 'package:intl/intl.dart';

import 'dashboard_model.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({AdminRepository? repository})
      : _repository = repository ?? AdminRepository(),
        super(const DashboardState());

  final AdminRepository _repository;

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final data = await _repository.getDashboardData();
      
      final stats = data['stats'] as Map<String, dynamic>;
      final activitiesData = data['activities'] as List<dynamic>;

      final activities = activitiesData.map((a) {
        final map = a as Map<String, dynamic>;
        final createdAt = DateTime.parse(map['created_at'] as String);
        
        return ActivityItem(
          id: map['id'] as String,
          type: _parseActivityType(map['type'] as String),
          title: map['title'] as String,
          subtitle: map['subtitle'] as String,
          timeAgo: _formatTimeAgo(createdAt),
        );
      }).toList();

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          sosAlertCount: stats['sos_alert_count'] as int,
          pendingVerificationCount: stats['pending_verification_count'] as int,
          openComplaintCount: stats['open_complaint_count'] as int,
          unreadNotificationsCount: stats['unread_notifications_count'] as int,
          activities: activities,
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

  Future<void> markAsRead(String activityId) async {
    try {
      final id = int.tryParse(activityId);
      if (id != null) {
        await _repository.markNotificationAsRead(id);
        // Refresh to update counts and UI
        await loadDashboard();
      }
    } catch (_) {
      // Silently fail or handle error
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllNotificationsAsRead();
      // No need to reload everything if we just want to clear badge, 
      // but usually the bell icon count depends on unread state.
      // We'll refresh to be safe.
      await loadDashboard();
    } catch (_) {}
  }

  ActivityType _parseActivityType(String type) {
    switch (type) {
      case 'caregiver':
        return ActivityType.caregiver;
      case 'complaint':
        return ActivityType.complaint;
      case 'booking':
        return ActivityType.booking;
      case 'central_fund':
        return ActivityType.central_fund;
      case 'user':
        return ActivityType.user;
      default:
        return ActivityType.user;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 0) return '${duration.inDays}d ago';
    if (duration.inHours > 0) return '${duration.inHours}h ago';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m ago';
    return 'Just now';
  }
}
