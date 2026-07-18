import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Bottom navigation bar for the admin shell, with "Complaints" shown
/// as the active tab.
///
/// Uses a fixed [_barHeight] and centers each item explicitly, plus
/// `Expanded` items, to avoid the stretched-pill / overflow bugs seen
/// on the verification nav bar. If your app already has a shared admin
/// bottom nav bar, prefer that instead of duplicating this per-feature.
class ComplaintBottomNavBar extends StatelessWidget {
  const ComplaintBottomNavBar({super.key});

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
            children: const [
              Expanded(
                child: _NavItem(icon: Icons.dashboard, label: 'Dashboard'),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.verified_user,
                  label: 'Verification',
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.assignment_late,
                  label: 'Complaints',
                  isActive: true,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.event_available,
                  label: 'Bookings',
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

    return Center(
      child: Material(
        color:
        isActive ? AppColors.primaryContainerLight : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {},
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
}