import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../caregiver_verification/cubit/caregiver_verification_cubit.dart';
import '../../complaint_management/cubit/complaint_management_cubit.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../user_management/cubit/user_management_cubit.dart';
import '../cubit/admin_shell_cubit.dart';
import 'admin_shell_view.dart';

/// Root entry point for the whole admin app. Provides every tab's
/// cubit exactly once here — they live for as long as the shell does,
/// not per tab-switch — which is what makes switching tabs instant
/// instead of re-triggering each screen's `loadX()` every time.
///
/// This replaces `DashboardPage`, `CaregiverVerificationPage`,
/// `UserManagementPage`, and `ComplaintManagementPage` as the way
/// those 4 screens get reached — they're rendered directly as
/// `...View()` bodies inside [AdminShellView]'s `IndexedStack` instead
/// of being separately routed pages. (Those `Page` classes still exist
/// and still work standalone if you need them — e.g. for testing a
/// single screen in isolation — they're just not part of the main flow
/// anymore.)
class AdminShellPage extends StatelessWidget {
  const AdminShellPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const AdminShellPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AdminShellCubit()),
        BlocProvider(create: (_) => DashboardCubit()..loadDashboard()),
        BlocProvider(
          create: (_) => CaregiverVerificationCubit()..loadCaregivers(),
        ),
        BlocProvider(create: (_) => UserManagementCubit()..loadUsers()),
        BlocProvider(
          create: (_) => ComplaintManagementCubit()..loadComplaints(),
        ),
      ],
      child: const AdminShellView(),
    );
  }
}