part of 'caregiver_notifications_cubit.dart';

class CaregiverNotificationsState extends Equatable {
  const CaregiverNotificationsState({
    this.allNotifications = const [],
    this.activeFilter,
  });

  final List<CaregiverNotification> allNotifications;

  /// Null means "All" — no filter applied.
  final NotificationType? activeFilter;

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

  CaregiverNotificationsState copyWith({
    List<CaregiverNotification>? allNotifications,
    NotificationType? activeFilter,
    bool clearFilter = false,
  }) {
    return CaregiverNotificationsState(
      allNotifications: allNotifications ?? this.allNotifications,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
    );
  }

  @override
  List<Object?> get props => [allNotifications, activeFilter];
}