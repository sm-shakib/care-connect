import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_model.dart';

/// Card representing a single caregiver awaiting/holding verification.

class CaregiverVerificationCard extends StatelessWidget {
  const CaregiverVerificationCard({
    required this.caregiver,
    this.onTap,
    super.key,
  });

  final CaregiverModel caregiver;
  final VoidCallback? onTap;

  _StatusStyle get _style => _StatusStyle.forStatus(caregiver.status);

  @override
  Widget build(BuildContext context) {
    final style = _style;
    return Material(
      color: AppColors.surfaceContainerLowestLight,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariantLight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(caregiver: caregiver, style: style),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            caregiver.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(style: style),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${caregiver.yearsExperience} years experience • '
                          '${caregiver.specialty}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariantLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '৳${caregiver.hourlyRate.toStringAsFixed(0)}/hr',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppColors.outlineLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.caregiver, required this.style});

  final CaregiverModel caregiver;
  final _StatusStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: style.avatarRingColor, width: 2),
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: Image.network(
                caregiver.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceContainerHighLight,
                  child: Icon(Icons.person, color: AppColors.outlineLight),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: style.dotBackgroundColor,
                border: Border.all(
                  color: AppColors.surfaceContainerLowestLight,
                  width: 2,
                ),
              ),
              child: Icon(
                style.dotIcon,
                size: 12,
                color: style.dotIconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.style});

  final _StatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: style.badgeBackgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        style.label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: style.badgeTextColor,
        ),
      ),
    );
  }
}

/// Bundles all status-dependent colors/icons/labels in one place so the
/// card widgets above stay purely presentational.
class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.avatarRingColor,
    required this.dotBackgroundColor,
    required this.dotIcon,
    required this.dotIconColor,
    required this.badgeBackgroundColor,
    required this.badgeTextColor,
  });

  final String label;
  final Color avatarRingColor;
  final Color dotBackgroundColor;
  final IconData dotIcon;
  final Color dotIconColor;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;

  factory _StatusStyle.forStatus(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return _StatusStyle(
          label: 'Pending',
          avatarRingColor: AppColors.primaryContainerLight,
          dotBackgroundColor: AppColors.tertiaryContainerLight,
          dotIcon: Icons.hourglass_empty,
          dotIconColor: AppColors.onTertiaryContainerLight,
          badgeBackgroundColor: AppColors.tertiaryContainerLight,
          badgeTextColor: AppColors.onTertiaryContainerLight,
        );
      case VerificationStatus.verified:
        return _StatusStyle(
          label: 'Verified',
          avatarRingColor: AppColors.primaryLight,
          dotBackgroundColor: AppColors.primaryLight,
          dotIcon: Icons.verified,
          dotIconColor: Colors.white,
          badgeBackgroundColor: AppColors.primaryContainerLight,
          badgeTextColor: AppColors.onPrimaryContainerLight,
        );
      case VerificationStatus.rejected:
        return _StatusStyle(
          label: 'Rejected',
          avatarRingColor: AppColors.errorLight,
          dotBackgroundColor: AppColors.errorLight,
          dotIcon: Icons.close,
          dotIconColor: Colors.white,
          badgeBackgroundColor: AppColors.errorContainerLight,
          badgeTextColor: AppColors.onErrorContainerLight,
        );
    }
  }
}