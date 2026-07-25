import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class MonitoringHeader extends StatelessWidget {
  const MonitoringHeader({
    required this.elderName,
    this.imageUrl = '',
    this.gender = 'Male',
    super.key,
  });

  final String elderName;
  final String imageUrl;
  final String gender;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.paleMint,
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          onBackgroundImageError: imageUrl.isNotEmpty
              ? (exception, stackTrace) => const Icon(Icons.error)
              : null,
          child: imageUrl.isEmpty
              ? Icon(
                  gender == 'Male' ? Icons.man : Icons.woman,
                  color: AppColors.primaryLight,
                  size: 26,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CareConnect',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                ),
              ),
              Text(
                'Monitoring $elderName',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.onSurfaceLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
