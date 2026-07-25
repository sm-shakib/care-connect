import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'admin_shell/cubit/admin_shell_cubit.dart';

/// The top-level admin sections shown in the shared bottom nav bar and
/// the dashboard's management grid.
enum AdminTab { dashboard, verification, users, complaints, bookings, central_fund }

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
  context.read<AdminShellCubit>().selectTab(tab);
}