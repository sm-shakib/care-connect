import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';

class LiveLocationCard extends StatelessWidget {
  const LiveLocationCard({
    required this.locationImage,
    required this.updatedTime,
    super.key,
  });

  final String locationImage;
  final String updatedTime;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Live Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceLight,
                    ),
                  ),
                ),
                Text(
                  updatedTime,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariantLight,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            locationImage,
            height: 170,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
