import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../admin_navigation.dart';
import '../../booking_management/view/booking_management_view.dart';
import '../../caregiver_verification/view/caregiver_verification_view.dart';
import '../../complaint_management/view/complaint_management_view.dart';
import '../../dashboard/view/dashboard_view.dart';
import '../../user_management/view/user_management_view.dart';
import '../../central_fund/view/central_fund_page.dart';
import '../cubit/admin_shell_cubit.dart';
import 'widgets/admin_bottom_nav_bar.dart';

/// The persistent admin shell: one `Scaffold`, one shared bottom nav
/// bar, and an `IndexedStack` holding all 5 built tab bodies.
///
/// `IndexedStack` builds and keeps *every* child mounted at all times —
/// only the selected one is painted/hit-testable. That's the whole fix
/// for the "reloading" feeling: switching tabs no longer destroys and
/// recreates a screen (and its cubit) each time, it just changes which
/// already-alive child is visible. Each tab's cubit is created once,
/// here, and stays alive for the shell's entire lifetime.
class AdminShellView extends StatelessWidget {
  const AdminShellView({super.key});

  static const _tabs = [
    AdminTab.dashboard,
    AdminTab.verification,
    AdminTab.users,
    AdminTab.complaints,
    AdminTab.bookings,
    AdminTab.central_fund,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminShellCubit, AdminTab>(
      builder: (context, selected) {
        final index = _tabs.indexOf(selected);

        return Scaffold(
          body: IndexedStack(
            index: index < 0 ? 0 : index,
            children: const [
              DashboardView(),
              CaregiverVerificationView(),
              UserManagementView(),
              ComplaintManagementView(),
              BookingManagementView(),
              CentralFundPage()
            ],
          ),
          bottomNavigationBar: AdminBottomNavBar(
            selected: selected,
            onSelect: (tab) => goToAdminTab(context, tab),
          ),
        );
      },
    );
  }
}