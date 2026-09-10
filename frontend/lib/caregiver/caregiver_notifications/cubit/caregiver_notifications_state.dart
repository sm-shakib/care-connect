part of 'caregiver_notifications_cubit.dart';

enum CaregiverNotificationsStatus { loading, success, failure }

class CaregiverNotificationsState extends Equatable {
  const CaregiverNotificationsState({
    this.status = CaregiverNotificationsStatus.loading,
    this.allNotifications = const [],
    this.activeFilter,
    this.errorMessage,
  });

  final CaregiverNotificationsStatus status;
  final List<CaregiverNotification> allNotifications;

  /// Null means "All" — no filter applied. Otherwise one of the raw
  /// backend `type` strings, e.g. `"sos_alert"`.
  final String? activeFilter;

  final String? errorMessage;

  bool get isLoading => status == CaregiverNotificationsStatus.loading;

  List<CaregiverNotification> get filteredNotifications {
    final list = activeFilter == null
        ? allNotifications
        : allNotifications.where((n) => n.type == activeFilter).toList();
    final sorted = [...list]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  List<CaregiverNotification> get todayNotifications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return filteredNotifications.where((n) => !n.timestamp.isBefore(today)).toList();
  }

  List<CaregiverNotification> get earlierNotifications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return filteredNotifications.where((n) => n.timestamp.isBefore(today)).toList();
  }

  /// Distinct types actually present in the data, for building the filter
  /// menu — kept dynamic rather than hardcoded so it never drifts from
  /// whatever the backend is really sending.
  List<String> get availableTypes {
    final types = allNotifications.map((n) => n.type).toSet().toList();
    types.sort();
    return types;
  }

  CaregiverNotificationsState copyWith({
    CaregiverNotificationsStatus? status,
    List<CaregiverNotification>? allNotifications,
    String? activeFilter,
    bool clearFilter = false,
    String? errorMessage,
  }) {
    return CaregiverNotificationsState(
      status: status ?? this.status,
      allNotifications: allNotifications ?? this.allNotifications,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, allNotifications, activeFilter, errorMessage];
}
