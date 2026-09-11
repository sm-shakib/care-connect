import 'package:flutter/material.dart';

/// A notification as the backend represents it — see
/// `backend/app/schemas/notification.py::NotificationOut`.
///
/// [type] is kept as the raw string the backend sends (currently just
/// `"binding_accepted"` and `"sos_alert"`) rather than a fixed Dart enum,
/// so a new type appearing server-side later degrades to a generic card
/// via [metaForType] instead of failing to parse.
class CaregiverNotification {
  const CaregiverNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.elderId,
    this.elderName,
    this.latitude,
    this.longitude,
  });

  factory CaregiverNotification.fromJson(Map<String, dynamic> json) {
    return CaregiverNotification(
      id: json['id'].toString(),
      type: json['type']?.toString() ?? 'general',
      title: json['title']?.toString() ?? '',
      message: json['body']?.toString() ?? '',
      timestamp:
          DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
      elderId: (json['elder_id'] as num?)?.toInt(),
      elderName: json['elder_name']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  /// Populated on `sos_alert` notifications — see [CaregiverNotification].
  final int? elderId;
  final String? elderName;
  final String? latitude;
  final String? longitude;

  bool get isCritical => type == 'sos_alert';
  bool get hasLocation => latitude != null && longitude != null;

  CaregiverNotification copyWith({bool? isRead}) {
    return CaregiverNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      elderId: elderId,
      elderName: elderName,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

/// Display metadata for a notification [CaregiverNotification.type].
class NotificationTypeMeta {
  const NotificationTypeMeta({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const _knownNotificationTypes = <String, NotificationTypeMeta>{
  'sos_alert': NotificationTypeMeta(
    label: 'SOS Alert',
    icon: Icons.sos_rounded,
  ),
  'binding_accepted': NotificationTypeMeta(
    label: 'Request Accepted',
    icon: Icons.link_rounded,
  ),
};

/// Falls back to a generic bell for any type not in
/// [_knownNotificationTypes] — new backend event types show up with a
/// sensible-looking card rather than breaking this UI.
NotificationTypeMeta metaForType(String type) =>
    _knownNotificationTypes[type] ??
    const NotificationTypeMeta(
      label: 'Update',
      icon: Icons.notifications_rounded,
    );
