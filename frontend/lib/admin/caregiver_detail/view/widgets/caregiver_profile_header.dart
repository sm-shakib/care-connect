import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_profile_model.dart';

/// Centered avatar + name + title + a single rating pill badge
/// (star + rating + review count combined into one primary-container
/// pill, not a separate plain row).
class CaregiverProfileHeader extends StatelessWidget {
  const CaregiverProfileHeader({required this.profile, super.key});

  final CaregiverProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryContainerLight,
                  width: 4,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  profile.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceContainerHighLight,
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.outlineLight,
                    ),
                  ),
                ),
              ),
            ),
            if (profile.isVerified)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border:
                    Border.all(color: AppColors.surfaceLight, width: 2),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.onPrimaryLight,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceLight,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          profile.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariantLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryContainerLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: AppColors.onPrimaryContainerLight,
              ),
              const SizedBox(width: 6),
              Text(
                '${profile.rating.toStringAsFixed(1)} '
                    '(${profile.reviewCount} reviews)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimaryContainerLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}