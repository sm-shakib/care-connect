import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../../admin_navigation.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import 'widgets/management_grid.dart';

/// Content body for the admin dashboard. Designed to fit inside the
/// shared [AdminShellView] Scaffold.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
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
                      onCentralFundTap: () =>
                          goToAdminTab(context, AdminTab.central_fund),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 360 ? 16 : 20;
  }
}
