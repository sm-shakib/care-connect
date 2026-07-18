import 'package:equatable/equatable.dart';

/// Which sub-system a recent-activity row relates to — drives the icon
/// and icon-background color on the dashboard's activity feed.
enum ActivityType { caregiver, complaint, booking }

/// A single row in the "Recent Activity" feed.
class ActivityItem extends Equatable {
  const ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
  });

  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;

  /// Pre-formatted relative time (e.g. "2m ago"). Kept as a static
  /// string rather than a `DateTime` diff since this is mock/demo data;
  /// swap for real elapsed-time formatting once wired to a backend.
  final String timeAgo;

  @override
  List<Object?> get props => [id, type, title, subtitle, timeAgo];
}