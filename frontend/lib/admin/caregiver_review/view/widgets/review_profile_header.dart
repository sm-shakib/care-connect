import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_application_model.dart';

/// Centered profile header: avatar with a verified badge, name, and
/// role/title underneath.
class ReviewProfileHeader extends StatelessWidget {
  const ReviewProfileHeader({required this.application, super.key});

  final CaregiverApplication application;

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
                  application.avatarUrl,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceLight, width: 2),
                ),
                child: Icon(
                  Icons.verified,
                  size: 18,
                  color: AppColors.onPrimaryLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          application.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceLight,
          ),
          textAlign: TextAlign.center,
        ),
        /*const SizedBox(height: 2),
        Text(
          application.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryLight,
          ),
          textAlign: TextAlign.center,
        ),*/
      ],
    );
  }
}