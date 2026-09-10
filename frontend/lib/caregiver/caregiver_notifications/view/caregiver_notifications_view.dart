import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubit/caregiver_notifications_cubit.dart';
import '../models/caregiver_notification.dart';
import '../widgets/notification_card.dart';
import '../widgets/notifications_top_bar.dart';

class CaregiverNotificationsView extends StatelessWidget {
  const CaregiverNotificationsView({super.key});

  /// Same Google Maps deep link `LiveLocationCard`/`FamilyNotificationsPage`
  /// use — opens the device's maps app centered on the given coordinates.
  static Future<void> _openInMaps(String latitude, String longitude) async {
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
        child: BlocBuilder<CaregiverNotificationsCubit, CaregiverNotificationsState>(
          builder: (context, state) {
            final cubit = context.read<CaregiverNotificationsCubit>();

            return Column(
              children: [
                const NotificationsTopBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _FilterButton(
                        availableTypes: state.availableTypes,
                        activeFilter: state.activeFilter,
                        onSelected: cubit.setFilter,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.status == CaregiverNotificationsStatus.failure
                          ? _ErrorView(
                              message: state.errorMessage,
                              onRetry: cubit.loadNotifications,
                            )
                          : RefreshIndicator(
                              onRefresh: cubit.refresh,
                              color: AppColors.darkTeal,
                              child: state.filteredNotifications.isEmpty
                                  ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: [
                                        SizedBox(
                                          height: 300,
                                          child: Center(
                                            child: Text(
                                              'No notifications found.',
                                              style: TextStyle(
                                                color:
                                                    colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        8,
                                        20,
                                        24,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (state
                                              .todayNotifications
                                              .isNotEmpty) ...[
                                            _SectionLabel(label: 'Today'),
                                            const SizedBox(height: 12),
                                            for (final notification
                                                in state.todayNotifications) ...[
                                              _NotificationCardEntry(
                                                notification: notification,
                                                cubit: cubit,
                                              ),
                                              const SizedBox(height: 16),
                                            ],
                                          ],
                                          if (state
                                              .earlierNotifications
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            _SectionLabel(label: 'Earlier'),
                                            const SizedBox(height: 12),
                                            for (final notification
                                                in state
                                                    .earlierNotifications) ...[
                                              _NotificationCardEntry(
                                                notification: notification,
                                                cubit: cubit,
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
            );
          },
        ),
      ),
    );
  }
}

/// Binds one [NotificationCard] to the cubit: tapping it marks it read
/// and, for an SOS alert with a location, opens maps too — the same
/// outcome as tapping the system push notification for that same alert.
class _NotificationCardEntry extends StatelessWidget {
  const _NotificationCardEntry({required this.notification, required this.cubit});

  final CaregiverNotification notification;
  final CaregiverNotificationsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return NotificationCard(
      notification: notification,
      onTap: () {
        cubit.markAsRead(notification.id);
        if (notification.isCritical && notification.hasLocation) {
          CaregiverNotificationsView._openInMaps(
            notification.latitude!,
            notification.longitude!,
          );
        }
      },
      onOpenMap: notification.hasLocation
          ? () => CaregiverNotificationsView._openInMaps(
                notification.latitude!,
                notification.longitude!,
              )
          : null,
      onAcknowledge: () => cubit.markAsRead(notification.id),
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

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.availableTypes,
    required this.activeFilter,
    required this.onSelected,
  });

  final List<String> availableTypes;
  final String? activeFilter;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String?>(
      initialValue: activeFilter,
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('All')),
        for (final type in availableTypes)
          PopupMenuItem(value: type, child: Text(metaForType(type).label)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              activeFilter == null ? 'Filter' : metaForType(activeFilter!).label,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
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
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
