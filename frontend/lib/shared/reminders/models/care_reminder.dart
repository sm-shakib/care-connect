import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// A non-medication reminder (e.g. therapy, hydration, exercise) shown
/// alongside an elder's medication schedule and appointments.
class CareReminder extends Equatable {
  const CareReminder({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isAttentionNeeded = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  /// True for reminders that should stand out visually (e.g. rendered
  /// with the error/attention color accent).
  final bool isAttentionNeeded;

  CareReminder copyWith({
    String? title,
    String? subtitle,
    IconData? icon,
    bool? isAttentionNeeded,
  }) {
    return CareReminder(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      isAttentionNeeded: isAttentionNeeded ?? this.isAttentionNeeded,
    );
  }

  @override
  List<Object?> get props => [id, title, subtitle, icon, isAttentionNeeded];

  /// Maps a backend-provided icon name string to the corresponding [IconData].
  static IconData mapIconNameToData(String? name) {
    switch (name) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'water_drop':
        return Icons.water_drop;
      case 'event':
        return Icons.event;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'restaurant':
        return Icons.restaurant;
      case 'bedtime':
        return Icons.bedtime;
      case 'spa':
        return Icons.spa;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  /// Maps an [IconData] to a string identifier used for storage in the backend.
  static String mapIconDataToName(IconData data) {
    if (data == Icons.fitness_center) return 'fitness_center';
    if (data == Icons.water_drop) return 'water_drop';
    if (data == Icons.event) return 'event';
    if (data == Icons.directions_walk) return 'directions_walk';
    if (data == Icons.restaurant) return 'restaurant';
    if (data == Icons.bedtime) return 'bedtime';
    if (data == Icons.spa) return 'spa';
    return 'notifications';
  }
}

/// Icon choices offered when adding/editing a [CareReminder].
const List<IconData> careReminderIconChoices = [
  Icons.fitness_center,
  Icons.water_drop,
  Icons.event,
  Icons.directions_walk,
  Icons.restaurant,
  Icons.bedtime,
  Icons.spa,
];
