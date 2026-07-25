import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/elderly_profile_model.dart';

/// Centered avatar + name + status pill.
class ElderlyProfileHeader extends StatelessWidget {
  const ElderlyProfileHeader({required this.profile, super.key});

  final ElderlyProfile profile;

  @override
  Widget build(BuildContext context) {
    final isActive = profile.status == AccountStatus.active;

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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
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
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryLight
                      : AppColors.outlineLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceLight, width: 2),
                ),
                child: Icon(
                  isActive ? Icons.check_circle : Icons.block,
                  size: 18,
                  color: Colors.white,
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
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryContainerLight
                : AppColors.errorContainerLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            isActive ? 'Active' : 'Suspended',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? AppColors.onPrimaryContainerLight
                  : AppColors.onErrorContainerLight,
            ),
          ),
        ),
      ],
    );
  }
}