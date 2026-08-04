import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/family_member_profile_model.dart';

/// "Linked Elderly Users (N)" section — the core of this page. Each
/// card is tappable (chevron affordance) and shows the elderly user's
/// relationship to this family member plus a solid "Primary" pill tag
/// where applicable.
class LinkedElderlyUsersSection extends StatelessWidget {
  const LinkedElderlyUsersSection({
    required this.users,
    this.onUserTap,
    super.key,
  });

  final List<LinkedElderlyUser> users;
  final ValueChanged<LinkedElderlyUser>? onUserTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Linked Elderly Users (${users.length})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariantLight,
          ),
        ),
        const SizedBox(height: 12),
        if (users.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariantLight),
            ),
            child: Text(
              'No elderly users linked yet.',
              style: TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
          )
        else
          Column(
            children: [
              for (final user in users) ...[
                _LinkedElderlyUserCard(
                  user: user,
                  onTap: () => onUserTap?.call(user),
                ),
                if (user != users.last) const SizedBox(height: 8),
              ],
            ],
          ),
      ],
    );
  }
}

class _LinkedElderlyUserCard extends StatelessWidget {
  const _LinkedElderlyUserCard({required this.user, this.onTap});

  final LinkedElderlyUser user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowestLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariantLight),
          ),
          child: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.network(
                    user.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceContainerHighLight,
                      child: Icon(Icons.person, color: AppColors.outlineLight),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.relationship,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                    if (user.isPrimaryContact) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainerLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Primary',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSecondaryContainerLight,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.outlineLight),
            ],
          ),
        ),
      ),
    );
  }
}