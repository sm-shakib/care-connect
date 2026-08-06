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
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(
          bottom: BorderSide(color: AppColors.outlineVariantLight),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryLight),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryLight,
          ),
        ),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activities = state.activities;

          if (activities.isEmpty) {
            return Center(
              child: Text(
                'No new notifications.',
                style: TextStyle(color: AppColors.onSurfaceVariantLight),
              ),
            );
          }

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _NotificationTile(
                      activity: activity,
                      onTap: () => _handleNotificationTap(context, activity),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, ActivityItem activity) {
    switch (activity.type) {
      case ActivityType.caregiver:
        Navigator.of(context).push(
          CaregiverReviewPage.route(applicationId: '1'),
        );
      case ActivityType.complaint:
        Navigator.of(context).push(
          ComplaintDetailPage.route(complaintId: 'CP-1024'),
        );
      case ActivityType.booking:
        goToAdminTab(context, AdminTab.bookings);
      case ActivityType.central_fund:
        goToAdminTab(context, AdminTab.central_fund);
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.activity, this.onTap});

  final ActivityItem activity;
  final VoidCallback? onTap;

  (IconData, Color, Color) get _iconStyle {
    switch (activity.type) {
      case ActivityType.caregiver:
        return (
          Icons.person_add,
          AppColors.primaryContainerLight,
          AppColors.onPrimaryContainerLight,
        );
      case ActivityType.complaint:
        return (
          Icons.report,
          AppColors.errorContainerLight,
          AppColors.onErrorContainerLight,
        );
      case ActivityType.booking:
      case ActivityType.central_fund:
        return (
          Icons.event,
          AppColors.tertiaryContainerLight,
          AppColors.onTertiaryContainerLight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, iconBg, iconFg) = _iconStyle;

    return Material(
      color: AppColors.surfaceContainerLowestLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariantLight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconFg, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariantLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.timeAgo,
                      style: TextStyle(fontSize: 12, color: AppColors.outlineLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
