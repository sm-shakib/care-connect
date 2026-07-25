import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';

/// Top bar for root dashboard screens: brand icon + title on the left,
/// notifications and profile actions on the right. Unlike
/// [CareConnectAppBar], this has no back arrow — it's meant for
/// landing/tab-style pages, not pages reached via push navigation.
class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    super.key,
    this.onNotificationsTap,
    this.onProfileTap,
    this.hasUnreadNotifications = false,
  });

  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.medical_services_rounded, color: AppColors.darkTeal, size: 32),
          const SizedBox(width: 10),
          Text(
            'CareConnect',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              //color: colorScheme.primary,
              color: AppColors.darkTeal,
            ),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(
                  //Icons.notifications_outlined,
                  Icons.notifications,
                  //color: colorScheme.onSurfaceVariant,
                  color: AppColors.darkTeal,
                ),
                onPressed: onNotificationsTap,
              ),
              if (hasUnreadNotifications)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.paleMint,
              child: const Icon(
                Icons.person,
                color: AppColors.darkTeal,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}