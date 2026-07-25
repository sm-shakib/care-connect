import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';

class AvailableCaregiversCard extends StatelessWidget {
  const AvailableCaregiversCard({
    required this.onTap,
    super.key,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.paleMint,
                child: const Icon(
                  Icons.group,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Caregivers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceLight,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Browse & Book',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariantLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppColors.outlineLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
