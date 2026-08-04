import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/family_member_profile_model.dart';

/// Centered avatar + name + status pill.
class FamilyMemberProfileHeader extends StatelessWidget {
  const FamilyMemberProfileHeader({required this.profile, super.key});

  final FamilyMemberProfile profile;

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
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerLight,
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
                  border: Border.all(color: AppColors.surfaceLight, width: 4),
                ),
                child: Icon(
                  isActive ? Icons.check_circle : Icons.block,
                  size: 16,
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppColors.onPrimaryContainerLight
                      : AppColors.onErrorContainerLight,
                ),
              ),
              Text(
                isActive ? 'Active' : 'Suspended',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.onPrimaryContainerLight
                      : AppColors.onErrorContainerLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}