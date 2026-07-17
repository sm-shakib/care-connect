import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// "Professional Summary" bio card.
class BioSection extends StatelessWidget {
  const BioSection({required this.bio, super.key});

  final String bio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariantLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bio,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.onSurfaceVariantLight,
            ),
          ),
        ],
      ),
    );
  }
}