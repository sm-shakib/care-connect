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
  /// (e.g. hydration goal), matching the reference design.
  final bool iconColorIsError;
}