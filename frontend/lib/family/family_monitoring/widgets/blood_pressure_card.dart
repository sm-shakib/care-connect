import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';

class BloodPressureCard extends StatelessWidget {
  const BloodPressureCard({
    required this.systolic,
    required this.diastolic,
    required this.status,
    super.key,
  });

  final int systolic;
  final int diastolic;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                  'Blood Pressure',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceLight,
                  ),
                ),
                Icon(
                  Icons.monitor_heart,
                  color: AppColors.primaryLight,
                ),
              ],
            ),
            const SizedBox(height: 18),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$systolic/$diastolic',
                    style: const TextStyle(
                      color: AppColors.onSurfaceLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 34,
                    ),
                  ),
                  const TextSpan(
                    text: ' mmHg',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariantLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.circle_outlined,
                  size: 15,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
