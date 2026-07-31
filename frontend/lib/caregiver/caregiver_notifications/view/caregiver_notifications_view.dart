import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/caregiver_notifications_cubit.dart';
import '../models/caregiver_notification.dart';
import '../widgets/notification_card.dart';
import '../widgets/notifications_top_bar.dart';

class CaregiverNotificationsView extends StatelessWidget {
  const CaregiverNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      //backgroundColor: colorScheme.surface,
      backgroundColor: const Color(0xFFFBFEFC),
      body: SafeArea(
        child: BlocBuilder<CaregiverNotificationsCubit, CaregiverNotificationsState>(
          builder: (context, state) {
            final cubit = context.read<CaregiverNotificationsCubit>();
            final hasAnyResults = state.filteredNotifications.isNotEmpty;

            return Column(
              children: [
                const NotificationsTopBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _FilterButton(
                        activeFilter: state.activeFilter,
                        onSelected: cubit.setFilter,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: !hasAnyResults
                      ? Center(
                    child: Text(
                      'No notifications found.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                      : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.todayNotifications.isNotEmpty) ...[
                          _SectionLabel(label: 'Today'),
                          const SizedBox(height: 12),
                          for (final notification in state.todayNotifications) ...[
                            NotificationCard(
                              notification: notification,
                              onCall: () {
                                // TODO: place a call to the patient/emergency contact.
                              },
                              onAcknowledge: () {
                                // TODO: mark this alert as acknowledged.
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                        if (state.earlierNotifications.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _SectionLabel(label: 'Earlier'),
                          const SizedBox(height: 12),
                          for (final notification in state.earlierNotifications) ...[
                            NotificationCard(
                              notification: notification,
                              onCall: () {
                                // TODO: place a call to the patient/emergency contact.
                              },
                              onAcknowledge: () {
                                // TODO: mark this alert as acknowledged.
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ],
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
  const _FilterButton({required this.activeFilter, required this.onSelected});

  final NotificationType? activeFilter;
  final ValueChanged<NotificationType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<NotificationType?>(
      initialValue: activeFilter,
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('All')),
        for (final type in NotificationType.values)
          PopupMenuItem(value: type, child: Text(type.label)),
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
              activeFilter?.label ?? 'Filter',
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}