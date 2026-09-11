import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/theme/app_colors.dart';

/// A bell [IconButton] carrying a live unread-notification count badge,
/// for a dashboard's AppBar — the caregiver and family notification
/// screens are the two currently backed by the real `/notifications/`
/// API (see `CaregiverNotificationsCubit`, `FamilyNotificationsPage`).
///
/// The count is fetched once on mount and again right after the pushed
/// page is popped, since both of those pages mark everything read as
/// soon as they load — by the time this widget is back on screen, the
/// badge should already be clear.
class NotificationBell extends StatefulWidget {
  const NotificationBell({
    required this.pageBuilder,
    super.key,
    this.color = AppColors.darkTeal,
    this.icon = Icons.notifications_outlined,
    this.size = 24,
  });

  /// Builds the notifications page to push when tapped.
  final WidgetBuilder pageBuilder;

  final Color color;
  final IconData icon;
  final double size;

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_refreshUnreadCount());
  }

  Future<void> _refreshUnreadCount() async {
    try {
      final response =
          await ApiClient().get<Map<String, dynamic>>('/notifications/unread-count');
      final count = (response.data?['count'] as num?)?.toInt() ?? 0;
      if (mounted) setState(() => _unreadCount = count);
    } on Exception {
      // Leave whatever count is already showing — the next successful
      // fetch (or the next page open) will correct it.
    }
  }

  Future<void> _open() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: widget.pageBuilder),
    );
    unawaited(_refreshUnreadCount());
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Badge(
        isLabelVisible: _unreadCount > 0,
        label: Text(_unreadCount > 9 ? '9+' : '$_unreadCount'),
        child: Icon(widget.icon, color: widget.color, size: widget.size),
      ),
      onPressed: _open,
    );
  }
}
