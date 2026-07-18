import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../admin_navigation.dart';

/// Bottom navigation bar for the admin shell, with "Verification" shown
/// as the active tab (pill-shaped highlight) as in the design.
///
/// Tapping another tab actually navigates there via [goToAdminTab].
///
/// If your app already has a shared admin bottom nav bar, prefer that
/// instead of duplicating this widget per-feature.
/*class VerificationBottomNavBar extends StatelessWidget {
  const VerificationBottomNavBar({super.key});

  static const double _barHeight = 64;
  static const AdminTab _current = AdminTab.verification;

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
                  onTap: () => goToAdminTab(
                    context,
                    AdminTab.dashboard,
                    current: _current,
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.verified_user,
                  label: 'Verification',
                  isActive: true,
                  onTap: () => goToAdminTab(
                    context,
                    AdminTab.verification,
                    current: _current,
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
                    current: _current,
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
                    current: _current,
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