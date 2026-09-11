import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class FamilyNotificationsPage extends StatefulWidget {
  const FamilyNotificationsPage({super.key});

  @override
  State<FamilyNotificationsPage> createState() => _FamilyNotificationsPageState();
}

class _FamilyNotificationsPageState extends State<FamilyNotificationsPage> {
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
      // caregiver side — see CaregiverNotificationsCubit.markAllAsRead.
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
        title: const Text('Notifications', style: TextStyle(color: AppColors.darkTeal, fontWeight: FontWeight.bold)),
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
                      final isSosAlert = item['type'] == 'sos_alert';
                      final latitude = item['latitude']?.toString();
                      final longitude = item['longitude']?.toString();
                      final hasLocation = latitude != null && longitude != null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: isSosAlert
                            ? AppColors.warningRed.withOpacity(0.08)
                            : AppColors.paleMint.withOpacity(0.18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSosAlert
                                ? AppColors.warningRed.withOpacity(0.4)
                                : AppColors.outlineVariantLight,
                          ),
                        ),
                        child: ListTile(
                          onTap: isSosAlert && hasLocation
                              ? () => _openInMaps(latitude, longitude)
                              : null,
                          leading: CircleAvatar(
                            backgroundColor: isSosAlert
                                ? AppColors.warningRed.withOpacity(0.15)
                                : AppColors.paleMint,
                            child: Icon(
                              isSosAlert
                                  ? Icons.sos_rounded
                                  : Icons.notifications_active,
                              color: isSosAlert
                                  ? AppColors.warningRed
                                  : AppColors.darkTeal,
                            ),
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
                              if (isSosAlert && hasLocation) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: const [
                                    Icon(Icons.map, size: 14, color: AppColors.darkTeal),
                                    SizedBox(width: 4),
                                    Text(
                                      'Tap to open in Google Maps',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkTeal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Future<void> _openInMaps(String latitude, String longitude) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
