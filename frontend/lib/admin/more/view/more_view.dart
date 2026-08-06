import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_colors.dart';
import '../../admin_navigation.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../notifications/view/notifications_page.dart';

/// A simple menu screen for "More" admin modules that didn't fit in
/// the primary bottom navigation bar.
class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        shape: Border(
          bottom: BorderSide(color: AppColors.outlineVariantLight),
        ),
        title: Text(
          'More',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: AppColors.primaryLight),
            onPressed: () {
              Navigator.of(context).push(
                NotificationsPage.route(context.read<DashboardCubit>()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _MoreMenuItem(
                  icon: Icons.group_outlined,
                  title: 'Users',
                  subtitle: 'Manage all platform accounts',
                  onTap: () => goToAdminTab(context, AdminTab.users),
                ),
                const SizedBox(height: 12),
                _MoreMenuItem(
                  icon: Icons.assignment_late_outlined,
                  title: 'Complaints',
                  subtitle: 'Review and resolve reported issues',
                  onTap: () => goToAdminTab(context, AdminTab.complaints),
                ),
                const SizedBox(height: 12),
                _MoreMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Central Fund',
                  subtitle: 'Monitor donations and aid requests',
                  onTap: () => goToAdminTab(context, AdminTab.central_fund),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  const _MoreMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryLight, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceLight,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariantLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.outlineLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
