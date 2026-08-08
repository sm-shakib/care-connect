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
