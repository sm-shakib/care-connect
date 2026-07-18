import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../admin_navigation.dart';

/// Bottom navigation bar for the admin shell, with "Dashboard" shown as
/// the active tab. Tapping another tab actually navigates there via
/// [goToAdminTab] — this is a real working tab bar, not just a static
/// mockup.
///
/// Uses a fixed [_barHeight] and centers each item explicitly, plus
/// `Expanded` items, matching the overflow-safe pattern established on
/// the other nav bars.
/*class DashboardBottomNavBar extends StatelessWidget {
  const DashboardBottomNavBar({super.key});

  static const double _barHeight = 64;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariantLight),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isActive: true,
                  onTap: () => goToAdminTab(
                    context,
                    AdminTab.dashboard,
                    current: AdminTab.dashboard,
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.verified_user,
                  label: 'Verification',
                  onTap: () => goToAdminTab(
                    context,
                    AdminTab.verification,
                    current: AdminTab.dashboard,
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.group,
                  label: 'Users',
                  onTap: () => goToAdminTab(
                    context,
                    AdminTab.users,
                    current: AdminTab.dashboard,
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.event_available,
                  label: 'Bookings',
                  onTap: () => goToAdminTab(
                    context,
                    AdminTab.bookings,
                    current: AdminTab.dashboard,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = isActive
        ? AppColors.onPrimaryContainerLight
        : (color ?? AppColors.onSurfaceVariantLight);

    return Center(
      child: Material(
        color:
        isActive ? AppColors.primaryContainerLight : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foreground, size: 22),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/