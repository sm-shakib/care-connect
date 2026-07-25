import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:intl/intl.dart';

import '../models/caregiver_notification.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    this.onCall,
    this.onAcknowledge,
  });

  final CaregiverNotification notification;
  final VoidCallback? onCall;
  final VoidCallback? onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeLabel = DateFormat('h:mm a').format(notification.timestamp);

    final accentColor = switch (notification.type) {
      NotificationType.medicineMissed => colorScheme.error,
      NotificationType.medicineTaken => colorScheme.tertiary,
      //NotificationType.careReminderMet => colorScheme.primary,
      NotificationType.careReminderMet => AppColors.darkTeal,
      NotificationType.paymentReceived => colorScheme.secondary,
    };

    final accentContainer = switch (notification.type) {
      NotificationType.medicineMissed => colorScheme.errorContainer,
      NotificationType.medicineTaken => colorScheme.tertiaryContainer,
      //NotificationType.careReminderMet => colorScheme.primaryContainer,
      NotificationType.careReminderMet => AppColors.paleMint,
      NotificationType.paymentReceived => colorScheme.secondaryContainer,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accentContainer.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.surface, width: 2),
          ),
          child: Icon(notification.type.icon, color: accentColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: notification.isCritical
                  ? accentContainer.withValues(alpha: 0.15)
                  : colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: notification.isCritical
                    ? accentContainer
                    : colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: notification.isCritical
                          ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'CRITICAL ALERT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      )
                          : Text(
                        notification.type.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
                    Text(
                      timeLabel,
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.type == NotificationType.paymentReceived &&
                      notification.amount != null
                      ? '${notification.message} — \$${notification.amount!.toStringAsFixed(2)}'
                      : notification.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                if (notification.isCritical) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onCall,
                          icon: const Icon(Icons.call, size: 18),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 46,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: onAcknowledge,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: accentContainer),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Icon(Icons.check_circle_outline, color: colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}