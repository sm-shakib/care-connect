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
          child: ClipOval(
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: 44,
                    height: 44,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      gender == 'Male' ? Icons.man : Icons.woman,
                      color: AppColors.primaryLight,
                      size: 26,
                    ),
                  )
                : Icon(
                    gender == 'Male' ? Icons.man : Icons.woman,
                    color: AppColors.primaryLight,
                    size: 26,
                  ),
          ),
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
