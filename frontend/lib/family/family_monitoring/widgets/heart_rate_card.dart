import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';

class HeartRateCard extends StatelessWidget {
  const HeartRateCard({
    required this.heartRate,
    required this.status,
    super.key,
  });

  final int heartRate;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Heart Rate',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceLight,
                  ),
                ),
                Icon(
                  Icons.favorite,
                  color: AppColors.warningRed,
                ),
              ],
            ),
            const SizedBox(height: 18),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$heartRate',
                    style: const TextStyle(
                      color: AppColors.onSurfaceLight,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: ' bpm',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariantLight,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '~ $status',
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
