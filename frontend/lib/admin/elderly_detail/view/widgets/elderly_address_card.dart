import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// "Home Address" card with a "View on Map" action.
class ElderlyAddressCard extends StatelessWidget {
  const ElderlyAddressCard({
    required this.address,
    this.onViewOnMap,
    super.key,
  });

  final String address;
  final VoidCallback? onViewOnMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryContainerLight.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on, color: AppColors.primaryLight),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOME ADDRESS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.onSurfaceVariantLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceLight,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onViewOnMap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View on Map',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.open_in_new,
                        size: 18,
                        color: AppColors.primaryLight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}