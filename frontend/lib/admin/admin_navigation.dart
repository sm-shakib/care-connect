import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'admin_shell/cubit/admin_shell_cubit.dart';

/// The top-level admin sections shown in the shared bottom nav bar and
/// the dashboard's management grid.
enum AdminTab {
  dashboard,
  verification,
  users,
  complaints,
  bookings,
  central_fund,
  more
}

/// Metadata for each admin tab to ensure consistent icons and labels
/// across the bottom nav bar and the "More" menu.
class AdminTabInfo {
  const AdminTabInfo({
    required this.tab,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.subtitle = '',
  });

  final AdminTab tab;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String subtitle;

  static const all = {
    AdminTab.dashboard: AdminTabInfo(
      tab: AdminTab.dashboard,
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    AdminTab.verification: AdminTabInfo(
      tab: AdminTab.verification,
      icon: Icons.verified_user_outlined,
      activeIcon: Icons.verified_user,
      label: 'Verification',
      subtitle: 'Review and approve caregiver applications',
    ),
    AdminTab.users: AdminTabInfo(
      tab: AdminTab.users,
      icon: Icons.group_outlined,
      activeIcon: Icons.group,
      label: 'Users',
      subtitle: 'Manage all platform accounts',
    ),
    AdminTab.complaints: AdminTabInfo(
      tab: AdminTab.complaints,
      icon: Icons.assignment_late_outlined,
      activeIcon: Icons.assignment_late,
      label: 'Complaints',
      subtitle: 'Review and resolve reported issues',
    ),
    AdminTab.bookings: AdminTabInfo(
      tab: AdminTab.bookings,
      icon: Icons.event_available_outlined,
      activeIcon: Icons.event_available,
      label: 'Bookings',
      subtitle: 'Track and manage service schedules',
    ),
    AdminTab.central_fund: AdminTabInfo(
      tab: AdminTab.central_fund,
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      label: 'Central Fund',
      subtitle: 'Monitor donations and aid requests',
    ),
    AdminTab.more: AdminTabInfo(
      tab: AdminTab.more,
      icon: Icons.more_horiz_outlined,
      activeIcon: Icons.more_horiz,
      label: 'More',
    ),
  };
}

/// Switches the persistent admin shell to [tab].
///
/// Requires an [AdminShellCubit] to be available above [context] — in
/// practice this means "called from somewhere inside `AdminShellPage`'s
/// widget tree", which is true for every screen that calls this
/// (Dashboard's grid tiles, the shared bottom nav bar) since they're
/// all tab bodies living inside the shell.
///
/// No page navigation happens here — switching tabs just updates which
/// already-alive `IndexedStack` child is shown. See `AdminShellView`
/// for why that matters (no reload/flicker).
void goToAdminTab(BuildContext context, AdminTab tab) {
  HapticFeedback.lightImpact();
  context.read<AdminShellCubit>().selectTab(tab);
}
