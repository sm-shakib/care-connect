import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Persistent, always-visible alert banner for active SOS emergencies.
/// This is deliberately not part of the bottom nav bar (SOS was dropped
/// from all the nav bars across this app) — critical alerts get
/// surfaced here instead, front and center on the dashboard.
class SosAlertBanner extends StatelessWidget {
  const SosAlertBanner({
    required this.alertCount,
    this.onTap,
    super.key,
  });

  final int alertCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (alertCount <= 0) return const SizedBox.shrink();

    return Material(
      color: AppColors.errorContainerLight.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.errorLight, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning, color: AppColors.onErrorLight),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$alertCount Active SOS Alert${alertCount == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onErrorContainerLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Immediate response required',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onErrorContainerLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.onErrorContainerLight),
            ],
          ),
        ),
      ),
    );
  }
}