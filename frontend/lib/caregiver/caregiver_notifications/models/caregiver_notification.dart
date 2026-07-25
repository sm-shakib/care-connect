import 'package:flutter/material.dart';

enum NotificationType { medicineTaken, medicineMissed, careReminderMet, paymentReceived }

class CaregiverNotification {
  const CaregiverNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.patientName,
    this.amount,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;

  /// Relevant for medicine/care-reminder notifications.
  final String? patientName;

  /// Relevant for payment-received notifications.
  final double? amount;

  bool get isCritical => type == NotificationType.medicineMissed;
}

extension NotificationTypeDisplay on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.medicineTaken:
        return 'Medicine Taken';
      case NotificationType.medicineMissed:
        return 'Medicine Missed';
      case NotificationType.careReminderMet:
        return 'Care Reminder';
      case NotificationType.paymentReceived:
        return 'Payment';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.medicineTaken:
        return Icons.check_circle;
      case NotificationType.medicineMissed:
        return Icons.home;
      case NotificationType.careReminderMet:
        return Icons.emoji_events;
      case NotificationType.paymentReceived:
        return Icons.payments;
    }
  }
}