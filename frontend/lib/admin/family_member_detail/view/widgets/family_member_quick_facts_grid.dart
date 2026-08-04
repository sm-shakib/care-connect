import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/family_member_profile_model.dart';

/// 2x2 grid of quick facts, built with `Row`/`Expanded` (not
/// `GridView`) — same overflow-safe pattern used throughout this app.
/// Content is centered per-cell, matching this design (Elderly
/// Profile's equivalent grid is left-aligned instead — don't assume
/// one alignment across all bento grids in this app).
class FamilyMemberQuickFactsGrid extends StatelessWidget {
  const FamilyMemberQuickFactsGrid({required this.profile, super.key});

  final FamilyMemberProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FactCard(
                icon: Icons.person,
                label: 'Gender',
                value: profile.gender,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FactCard(
                icon: Icons.calendar_today,
                label: 'Age',
                value: '${profile.age}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FactCard(
                icon: Icons.call,
                label: 'Phone',
                value: profile.phone,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FactCard(
                icon: Icons.mail,
                label: 'Email',
                value: profile.email,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Fixed height (not aspect-ratio) so long values (emails/phones)
      // can't push the card taller and break the 2x2 grid's alignment.
      height: 128,
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryLight),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariantLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceLight,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}