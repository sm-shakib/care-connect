import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// The 2x2 grid of management entry points. Built with `Row`/`Expanded`
/// and a fixed tile height (not `GridView`), matching the overflow-safe
/// pattern used elsewhere — a fixed-height tile with `mainAxisAlignment:
/// spaceBetween` can't overflow the way a `GridView` item with a
/// mismatched aspect ratio can.
class ManagementGrid extends StatelessWidget {
  const ManagementGrid({
    required this.pendingVerificationCount,
    required this.openComplaintCount,
    required this.onVerificationTap,
    required this.onUsersTap,
    required this.onComplaintsTap,
    required this.onBookingsTap,
    super.key,
  });

  final int pendingVerificationCount;
  final int openComplaintCount;
  final VoidCallback onVerificationTap;
  final VoidCallback onUsersTap;
  final VoidCallback onComplaintsTap;
  final VoidCallback onBookingsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ManagementTile(
                icon: Icons.verified_user,
                title: 'Verification',
                subtitle: 'Pending Reviews',
                backgroundColor: AppColors.primaryContainerLight,
                foregroundColor: AppColors.onPrimaryContainerLight,
                badge: '$pendingVerificationCount NEW',
                badgeBackground: AppColors.primaryLight,
                badgeForeground: AppColors.onPrimaryLight,
                onTap: onVerificationTap,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ManagementTile(
                icon: Icons.group,
                title: 'Users',
                subtitle: 'Account Control',
                backgroundColor: AppColors.secondaryContainerLight,
                foregroundColor: AppColors.onSecondaryContainerLight,
                onTap: onUsersTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ManagementTile(
                icon: Icons.report,
                title: 'Complaints',
                subtitle: 'Conflict Resolution',
                backgroundColor: AppColors.surfaceContainerHighestLight,
                foregroundColor: AppColors.onSurfaceLight,
                border: AppColors.outlineVariantLight,
                badge: '$openComplaintCount OPEN',
                badgeBackground: AppColors.errorLight,
                badgeForeground: AppColors.onErrorLight,
                onTap: onComplaintsTap,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ManagementTile(
                icon: Icons.event_available,
                title: 'Bookings',
                subtitle: 'System Schedules',
                backgroundColor: AppColors.tertiaryContainerLight,
                foregroundColor: AppColors.onTertiaryContainerLight,
                onTap: onBookingsTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ManagementTile extends StatelessWidget {
  const _ManagementTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
    this.badge,
    this.badgeBackground,
    this.badgeForeground,
    this.border,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeBackground;
  final Color? badgeForeground;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 160,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: border != null ? Border.all(color: border!) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: foregroundColor, size: 32),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBackground,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: badgeForeground,
                        ),
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: foregroundColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: foregroundColor.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}