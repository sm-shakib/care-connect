import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/elderly_profile_model.dart';

/// "Linked Family Members (N)" section with an Edit action and a list
/// of tappable family-member rows.
class LinkedFamilyMembersSection extends StatelessWidget {
  const LinkedFamilyMembersSection({
    required this.members,
    this.onEdit,
    this.onMemberTap,
    super.key,
  });

  final List<LinkedFamilyMember> members;
  final VoidCallback? onEdit;
  final ValueChanged<LinkedFamilyMember>? onMemberTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Linked Family Members (${members.length})',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: onEdit,
              child: Text(
                'Edit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
        if (members.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariantLight),
            ),
            child: Text(
              'No family members linked yet.',
              style: TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
          )
        else
          Column(
            children: [
              for (final member in members) ...[
                _FamilyMemberRow(
                  member: member,
                  onTap: () => onMemberTap?.call(member),
                ),
                if (member != members.last) const SizedBox(height: 8),
              ],
            ],
          ),
      ],
    );
  }
}

class _FamilyMemberRow extends StatelessWidget {
  const _FamilyMemberRow({required this.member, this.onTap});

  final LinkedFamilyMember member;
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
          padding: const EdgeInsets.all(12),
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
                    member.avatarUrl,
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
                    Text(
                      member.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      member.relationship,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onSurfaceVariantLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (member.isPrimaryContact)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          ),
        ),
      ),
    );
  }
}