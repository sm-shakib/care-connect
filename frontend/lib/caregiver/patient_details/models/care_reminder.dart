import 'package:flutter/material.dart';

class CareReminder {
  const CareReminder({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColorIsError = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  /// True for reminders that should render with the error color accent
  final bool iconColorIsError;

  CareReminder copyWith({
    String? title,
    String? subtitle,
    IconData? icon,
    bool? iconColorIsError,
  }) {
    return CareReminder(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      iconColorIsError: iconColorIsError ?? this.iconColorIsError,
    );
  }
}