import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../../admin_navigation.dart';
import '../../booking_management/view/booking_management_view.dart';
import '../../caregiver_verification/view/caregiver_verification_view.dart';
import '../../complaint_management/view/complaint_management_view.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../more/view/more_view.dart';
import '../../notifications/view/notifications_page.dart';
import '../../user_management/view/user_management_view.dart';
import '../../central_fund/view/central_fund_page.dart';
import '../cubit/admin_shell_cubit.dart';
import '../cubit/admin_shell_state.dart';
import 'widgets/admin_bottom_nav_bar.dart';

/// The persistent admin shell: one `Scaffold`, one shared bottom nav
/// bar, and an `IndexedStack` holding all built tab bodies.
///
/// Refactored to have a single shared Scaffold and AppBar, matching
/// the persistent feel of the family app. Switching tabs now only
/// updates the Title and Body, keeping the UI steady and fluid.
class AdminShellView extends StatelessWidget {
  const AdminShellView({super.key});

  /// The order here must match the [AdminTab] enum order exactly for
  /// the [IndexedStack] to map correctly.
  static const _allTabs = [
    AdminTab.verification,
    AdminTab.users,
    AdminTab.complaints,
    AdminTab.bookings,
    AdminTab.central_fund,
    AdminTab.more,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminShellCubit, AdminShellState>(
      builder: (context, state) {
        final selected = state.selectedTab;
        final index = _allTabs.indexOf(selected);

        return Scaffold(
          backgroundColor: AppColors.surfaceLight,
          appBar: _buildAppBar(context, selected),
          floatingActionButton: _buildFAB(context, selected),
          body: IndexedStack(
            // If the selected tab isn't in our list (e.g. Dashboard),
            // default to Users (index 1).
            index: index < 0 ? 1 : index,
            children: const [
              CaregiverVerificationView(),
              UserManagementView(),
              ComplaintManagementView(),
              BookingManagementView(),
              CentralFundPage(),
              MoreView(),
            ],
          ),
          bottomNavigationBar: AdminBottomNavBar(
            key: const PageStorageKey('admin_bottom_nav_bar'),
            selected: selected,
            onSelect: (tab) => goToAdminTab(context, tab),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AdminTab selected) {
    Widget title;
    double? titleSpacing;

    switch (selected) {
      case AdminTab.dashboard:
        titleSpacing = 20;
        title = Row(
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
        );
      case AdminTab.verification:
        title = const Text('Verification');
      case AdminTab.users:
        title = const Text('User Management');
      case AdminTab.complaints:
        title = const Text('Complaints');
      case AdminTab.bookings:
        title = const Text('Bookings');
      case AdminTab.central_fund:
        title = const Text('Central Fund');
      case AdminTab.more:
        title = const Text('More');
    }

    return AppBar(
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: titleSpacing,
      shape: Border(
        bottom: BorderSide(color: AppColors.outlineVariantLight),
      ),
      title: DefaultTextStyle(
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryLight,
          fontFamily: Theme.of(context).textTheme.titleLarge?.fontFamily,
        ),
        child: title,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.primaryLight),
          onPressed: () {
            Navigator.of(context).push(
              NotificationsPage.route(context.read<DashboardCubit>()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget? _buildFAB(BuildContext context, AdminTab selected) {
    /*if (selected == AdminTab.users) {
      return FloatingActionButton(
        onPressed: () {
          // TODO(careconnect): navigate to the add-user flow.
        },
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        //child: const Icon(Icons.person_add, size: 28),
      );
    }*/
    return null;
  }
}
