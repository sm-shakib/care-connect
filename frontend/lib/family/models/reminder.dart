import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Reminder extends Equatable {
  const Reminder({
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
  final bool iconColorIsError;

  @override
  List<Object?> get props => [id, title, subtitle, icon, iconColorIsError];

  Reminder copyWith({
    String? id,
    String? title,
    String? subtitle,
    IconData? icon,
    bool? iconColorIsError,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      iconColorIsError: iconColorIsError ?? this.iconColorIsError,
    );
  }
}
