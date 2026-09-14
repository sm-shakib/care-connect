import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_colors.dart';
import '../../admin_navigation.dart';
import '../../caregiver_review/view/caregiver_review_page.dart';
import '../../complaint_detail/view/complaint_detail_page.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../dashboard/cubit/dashboard_model.dart';
import '../../dashboard/cubit/dashboard_state.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      body: SafeArea(
        child: Column(
          children: [
            _NotificationsTopBar(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final activities = state.activities;

                  if (activities.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 300,
                          child: Center(
                            child: Text(
                              'No new notifications.',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<DashboardCubit>().loadDashboard(),
                    color: AppColors.darkTeal,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel(label: 'Recent Activity'),
                          const SizedBox(height: 12),
                          for (final activity in activities) ...[
                            _NotificationCard(
                              activity: activity,
                              onTap: () => _handleNotificationTap(context, activity),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, ActivityItem activity) {
    // Mark as read
    context.read<DashboardCubit>().markAsRead(activity.id);

    switch (activity.type) {
      case ActivityType.caregiver:
        // For real notifications, we might want to pass the real ID if available in subtitle/title
        // or add a metadata field to ActivityItem. For now, go to verification tab.
        goToAdminTab(context, AdminTab.verification);
      case ActivityType.complaint:
        goToAdminTab(context, AdminTab.complaints);
      case ActivityType.booking:
        goToAdminTab(context, AdminTab.bookings);
      case ActivityType.central_fund:
        goToAdminTab(context, AdminTab.central_fund);
      case ActivityType.user:
        goToAdminTab(context, AdminTab.users);
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.activity, this.onTap});

  final ActivityItem activity;
  final VoidCallback? onTap;

  (IconData, String) get _meta {
    switch (activity.type) {
      case ActivityType.caregiver:
        return (Icons.person_add, 'Caregiver');
      case ActivityType.complaint:
        return (Icons.report, 'Complaint');
      case ActivityType.booking:
        return (Icons.event, 'Booking');
      case ActivityType.central_fund:
        return (Icons.account_balance_wallet, 'Central Fund');
      case ActivityType.user:
        return (Icons.person, 'User');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, label) = _meta;
    
    final accentColor = AppColors.darkTeal;
    final accentContainer = AppColors.paleMint;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentContainer,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 2),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                      Text(
                        activity.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
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
