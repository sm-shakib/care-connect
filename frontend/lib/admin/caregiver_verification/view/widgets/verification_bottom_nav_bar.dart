import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Bottom navigation bar for the admin shell, with "Verification" shown
/// as the active tab (pill-shaped highlight) as in the design.
///
/// If your app already has a shared admin bottom nav bar, prefer that
/// instead of duplicating this widget per-feature.
class VerificationBottomNavBar extends StatelessWidget {
  const VerificationBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariantLight),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.dashboard, label: 'Dashboard'),
            _NavItem(
              icon: Icons.verified_user,
              label: 'Verification',
              isActive: true,
            ),
            _NavItem(icon: Icons.group, label: 'Users'),
            _NavItem(icon: Icons.event_available, label: 'Bookings'),

          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.color,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = isActive
        ? AppColors.onPrimaryContainerLight
        : (color ?? AppColors.onSurfaceVariantLight);

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );

    return Material(
      color: isActive ? AppColors.primaryContainerLight : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {},
        child: content,
      ),
    );
  }
}