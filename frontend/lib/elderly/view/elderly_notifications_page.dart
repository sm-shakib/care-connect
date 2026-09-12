import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:intl/intl.dart';

/// Backed by the same `/notifications/` API as the caregiver and family
/// notification screens — see `CaregiverNotificationsCubit` and
/// `FamilyNotificationsPage`. Elders don't currently receive any
/// location-bearing notification type, so unlike those two this has no
/// "Open in Maps" affordance.
class ElderlyNotificationsPage extends StatefulWidget {
  const ElderlyNotificationsPage({super.key});

  @override
  State<ElderlyNotificationsPage> createState() =>
      _ElderlyNotificationsPageState();
}

class _ElderlyNotificationsPageState extends State<ElderlyNotificationsPage> {
  List<Map<String, dynamic>> _notifications = const <Map<String, dynamic>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await ApiClient().get<List<dynamic>>('/notifications/');
      final data = response.data ?? const <dynamic>[];
      if (mounted) {
        setState(() {
          _notifications = data
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          _isLoading = false;
        });
      }
      // Opening this page is itself the "read" action, same as the
      // caregiver/family sides — see CaregiverNotificationsCubit.markAllAsRead.
      if (_notifications.any((n) => n['is_read'] != true)) {
        unawaited(_markAllAsRead());
      }
    } on Exception {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    if (mounted) {
      setState(() {
        _notifications = [
          for (final n in _notifications) {...n, 'is_read': true},
        ];
      });
    }
    try {
      await ApiClient().put<void>('/notifications/read-all');
    } on Exception {
      // Best-effort: the list already reflects "read" locally; a failed
      // sync just means it may show unread again after the next refresh.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFBFEFC),
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(color: AppColors.outlineVariantLight),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.darkTeal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('No new notifications.'))
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      final meta = _metaForType(item['type']?.toString());

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: AppColors.paleMint.withValues(alpha: 0.18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: AppColors.outlineVariantLight,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                meta.color.withValues(alpha: 0.15),
                            child: Icon(meta.icon, color: meta.color),
                          ),
                          title: Text(
                            (item['title'] ?? '').toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text((item['body'] ?? '').toString()),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime((item['created_at'] ?? '').toString()),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat.yMMMd().add_jm().format(date);
    } catch (_) {
      return isoDate;
    }
  }
}

class _NotificationTypeMeta {
  const _NotificationTypeMeta({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

/// Falls back to a generic bell for any type not listed here — a new
/// backend event type still shows up with a sensible-looking card.
_NotificationTypeMeta _metaForType(String? type) {
  switch (type) {
    case 'binding_request':
      return const _NotificationTypeMeta(
        icon: Icons.people_alt_rounded,
        color: AppColors.darkTeal,
      );
    case 'binding_accepted':
      return const _NotificationTypeMeta(
        icon: Icons.link_rounded,
        color: AppColors.darkTeal,
      );
    case 'sos_alert':
      return const _NotificationTypeMeta(
        icon: Icons.sos_rounded,
        color: AppColors.warningRed,
      );
    case 'appointment_reminder':
      return const _NotificationTypeMeta(
        icon: Icons.event_available_rounded,
        color: AppColors.darkTeal,
      );
    default:
      return const _NotificationTypeMeta(
        icon: Icons.notifications_active,
        color: AppColors.darkTeal,
      );
  }
}
