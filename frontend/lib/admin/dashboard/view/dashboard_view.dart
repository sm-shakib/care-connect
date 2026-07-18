import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../../admin_navigation.dart';
import '../../caregiver_review/view/caregiver_review_page.dart';
import '../../complaint_detail/view/complaint_detail_page.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_model.dart';
import '../cubit/dashboard_state.dart';
//import 'widgets/dashboard_bottom_nav_bar.dart';
import 'widgets/management_grid.dart';
import 'widgets/recent_activity_section.dart';
import 'widgets/sos_alert_banner.dart';

/// Presentational scaffold for the admin dashboard — the app's home
/// screen. No back button (this is the root of the admin tab flow).
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(context),
      //bottomNavigationBar: const DashboardBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO(careconnect): open a real "quick admin action" flow
          // (e.g. broadcast announcement, manual booking, etc).
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Quick actions coming soon.')),
            );
        },
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DashboardStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Something went wrong.',
                  style: TextStyle(color: AppColors.onSurfaceVariantLight),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: RefreshIndicator(
                  onRefresh: context.read<DashboardCubit>().loadDashboard,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      _horizontalPadding(context),
                      16,
                      _horizontalPadding(context),
                      // Extra bottom room so content clears the FAB.
                      100,
                    ),
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurfaceLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage platform operations and critical alerts.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.onSurfaceVariantLight,
                        ),
                      ),
                      const SizedBox(height: 20),
                      /*SosAlertBanner(
                        alertCount: state.sosAlertCount,
                        onTap: () {
                          // TODO(careconnect): no SOS management page
                          // has been built yet — replace with a real
                          // push once it exists.
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text('SOS alerts coming soon.'),
                              ),
                            );
                        },
                      ),*/
                      //if (state.sosAlertCount > 0) const SizedBox(height: 20),
                      ManagementGrid(
                        pendingVerificationCount:
                        state.pendingVerificationCount,
                        openComplaintCount: state.openComplaintCount,
                        onVerificationTap: () =>
                            goToAdminTab(context, AdminTab.verification),
                        onUsersTap: () =>
                            goToAdminTab(context, AdminTab.users),
                        onComplaintsTap: () =>
                            goToAdminTab(context, AdminTab.complaints),
                        onBookingsTap: () =>
                            goToAdminTab(context, AdminTab.bookings),
                      ),
                      const SizedBox(height: 24),
                      RecentActivitySection(
                        activities: state.activities,
                        onHistoryTap: () {
                          // TODO(careconnect): no activity-history page
                          // has been built yet.
                          // ScaffoldMessenger.of(context)
                          //   ..hideCurrentSnackBar()
                          //   ..showSnackBar(
                          //     const SnackBar(
                          //       content: Text('Activity history coming soon.'),
                          //     ),
                          //   );
                        },
                        onActivityTap: (activity) =>
                            _handleActivityTap(context, activity),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleActivityTap(BuildContext context, ActivityItem activity) {
    switch (activity.type) {
      case ActivityType.caregiver:
      // The mock activity corresponds to caregiver id '1' (Adib Khan)
      // in caregiver_verification's mock data.
        Navigator.of(context).push(
          CaregiverReviewPage.route(applicationId: '1'),
        );
      case ActivityType.complaint:
        Navigator.of(context).push(
          ComplaintDetailPage.route(complaintId: 'CP-1024'),
        );
      case ActivityType.booking:
      // TODO(careconnect): no Bookings feature/page has been built
      // yet — replace with a real push once it exists.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Bookings management is coming soon.')),
          );
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      shape: Border(
        bottom: BorderSide(color: AppColors.outlineVariantLight),
      ),
      titleSpacing: 20,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medical_services_rounded, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Text(
            'CareConnect',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: AppColors.primaryLight,
                ),
                onPressed: () {
                  // TODO(careconnect): no notifications page has been
                  // built yet.
                  /*ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Notifications coming soon.')),
                    );
                   */
                },
              ),
              /*Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceLight, width: 2),
                  ),
                ),
              ),
              */
            ],
          ),
        ),
      ],
    );
  }

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 360 ? 16 : 20;
  }
}