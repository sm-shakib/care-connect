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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
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
      if (_notifications.any((n) => n['is_read'] != true)) {
        unawaited(_markAllAsRead());
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to load notifications. Please try again.';
        });
      }
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
      // Best-effort
    }
  }

  List<Map<String, dynamic>> get _todayNotifications {
    final now = DateTime.now();
    return _notifications.where((n) {
      final date = DateTime.tryParse(n['created_at']?.toString() ?? '')?.toLocal();
      if (date == null) return false;
      return date.year == now.year && date.month == now.month && date.day == now.day;
    }).toList();
  }

  List<Map<String, dynamic>> get _earlierNotifications {
    final now = DateTime.now();
    return _notifications.where((n) {
      final date = DateTime.tryParse(n['created_at']?.toString() ?? '')?.toLocal();
      if (date == null) return true;
      return !(date.year == now.year && date.month == now.month && date.day == now.day);
    }).toList();
  }

  Future<void> _openInMaps(String latitude, String longitude) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      body: SafeArea(
        child: Column(
          children: [
            _NotificationsTopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _ErrorView(
                          message: _errorMessage,
                          onRetry: _fetchNotifications,
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchNotifications,
                          color: AppColors.darkTeal,
                          child: _notifications.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height: 300,
                                      child: Center(
                                        child: Text(
                                          'No notifications found.',
                                          style: TextStyle(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_todayNotifications.isNotEmpty) ...[
                                        const _SectionLabel(label: 'Today'),
                                        const SizedBox(height: 12),
                                        for (final notification in _todayNotifications) ...[
                                          _NotificationCard(
                                            notification: notification,
                                            onOpenMap: _openInMaps,
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ],
                                      if (_earlierNotifications.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        const _SectionLabel(label: 'Earlier'),
                                        const SizedBox(height: 12),
                                        for (final notification in _earlierNotifications) ...[
                                          _NotificationCard(
                                            notification: notification,
                                            onOpenMap: _openInMaps,
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ],
                                    ],
                                  ),
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    this.onOpenMap,
  });

  final Map<String, dynamic> notification;
  final Function(String, String)? onOpenMap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final createdAt = DateTime.tryParse(notification['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now();
    final timeLabel = DateFormat('h:mm a').format(createdAt);
    final type = notification['type']?.toString() ?? 'general';
    final meta = _metaForType(type);
    final isRead = notification['is_read'] as bool? ?? false;
    final isSosAlert = type == 'sos_alert';
    final latitude = notification['latitude']?.toString();
    final longitude = notification['longitude']?.toString();
    final hasLocation = latitude != null && longitude != null;

    final accentColor = isSosAlert ? AppColors.warningRed : AppColors.darkTeal;
    final accentContainer = isSosAlert
        ? AppColors.warningRed.withValues(alpha: 0.15)
        : AppColors.paleMint;

    return InkWell(
      onTap: isSosAlert && hasLocation ? () => onOpenMap?.call(latitude, longitude) : null,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
                child: Icon(meta.icon, color: accentColor, size: 22),
              ),
              if (!isRead)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSosAlert ? accentContainer : colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSosAlert
                      ? accentColor.withValues(alpha: 0.4)
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
                        child: isSosAlert
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'SOS ALERT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                meta.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                      ),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (notification['title'] ?? '').toString(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (notification['body'] ?? '').toString(),
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  if (isSosAlert && hasLocation) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => onOpenMap?.call(latitude, longitude),
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text('Open in Maps'),
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
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}

class _NotificationsTopBar extends StatelessWidget {
  const _NotificationsTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
            onPressed: onBack,
          ),
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTeal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 40),
            const SizedBox(height: 12),
            Text(
              message ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _NotificationTypeMeta {
  const _NotificationTypeMeta({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

_NotificationTypeMeta _metaForType(String? type) {
  switch (type) {
    case 'binding_request':
      return const _NotificationTypeMeta(
        label: 'Request',
        icon: Icons.people_alt_rounded,
      );
    case 'binding_accepted':
      return const _NotificationTypeMeta(
        label: 'Accepted',
        icon: Icons.link_rounded,
      );
    case 'sos_alert':
      return const _NotificationTypeMeta(
        label: 'SOS Alert',
        icon: Icons.sos_rounded,
      );
    case 'appointment_reminder':
      return const _NotificationTypeMeta(
        label: 'Appointment',
        icon: Icons.event_available_rounded,
      );
    default:
      return const _NotificationTypeMeta(
        label: 'Update',
        icon: Icons.notifications_active,
      );
  }
}
