import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// "Home Address" card with a "View on Map" action. Uses a
/// tertiary-tinted icon container, matching this design (the
/// equivalent card on Elderly Profile uses primary instead).
class FamilyMemberAddressCard extends StatelessWidget {
  const FamilyMemberAddressCard({
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainerLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.location_on, color: AppColors.tertiaryLight),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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