import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/elderly_profile_model.dart';

/// 2x2 grid of quick facts, built with `Row`/`Expanded` (not
/// `GridView`) — same overflow-safe pattern used throughout this app.
class ElderlyQuickFactsGrid extends StatelessWidget {
  const ElderlyQuickFactsGrid({required this.profile, super.key});

  final ElderlyProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FactCard(
                icon: profile.gender.toLowerCase() == 'female'
                    ? Icons.female
                    : Icons.male,
                label: 'Gender',
                value: profile.gender,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FactCard(
                icon: Icons.cake,
                label: 'Age',
                value: '${profile.age} Years',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryLight),
          const SizedBox(height: 4),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}