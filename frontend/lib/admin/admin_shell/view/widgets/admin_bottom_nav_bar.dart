import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../admin_navigation.dart';

/// The single, shared bottom navigation bar for the admin shell.
/// Replaces the four separate (and previously non-functional)
/// per-feature nav bars — this is the only one now.
///
/// Purely presentational: [selected] + [onSelect] are passed in by
/// [AdminShellView], which owns the actual tab-switching logic via
/// [AdminShellCubit].
///
/// Fixed [_barHeight] + `Expanded` items + centered content — same
/// overflow-safe pattern used throughout this app, now sized for 5
/// items instead of 4.
class AdminBottomNavBar extends StatelessWidget {
  const AdminBottomNavBar({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final AdminTab selected;
  final ValueChanged<AdminTab> onSelect;

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
                  isActive: selected == AdminTab.dashboard,
                  onTap: () => onSelect(AdminTab.dashboard),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.verified_user,
                  label: 'Verification',
                  isActive: selected == AdminTab.verification,
                  onTap: () => onSelect(AdminTab.verification),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.group,
                  label: 'Users',
                  isActive: selected == AdminTab.users,
                  onTap: () => onSelect(AdminTab.users),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.assignment_late,
                  label: 'Complaints',
                  isActive: selected == AdminTab.complaints,
                  onTap: () => onSelect(AdminTab.complaints),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.event_available,
                  label: 'Bookings',
                  isActive: selected == AdminTab.bookings,
                  onTap: () => onSelect(AdminTab.bookings),
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final foreground = isActive
        ? AppColors.onPrimaryContainerLight
        : AppColors.onSurfaceVariantLight;

    return Center(
      child: Material(
        color:
        isActive ? AppColors.primaryContainerLight : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foreground, size: 20),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
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