import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_profile_model.dart';

/// Grid of key caregiver profile attributes (Experience, Hourly Rate,
/// Phone, Email, Address), styled to match [ElderlyQuickFactsGrid].
class CaregiverQuickFactsGrid extends StatelessWidget {
  const CaregiverQuickFactsGrid({required this.profile, super.key});

  final CaregiverProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariantLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_ind, color: AppColors.primaryLight),
              const SizedBox(width: 12),
              Text(
                'QUICK FACTS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _FactRow(
            icon: Icons.person,
            label: 'Gender',
            value: profile.gender,
          ),
          const SizedBox(height: 16),
          _FactRow(
            icon: Icons.work_history,
            label: 'Experience',
            value: '${profile.experienceYears} Years',
          ),
          const SizedBox(height: 16),
          _FactRow(
            icon: Icons.payments,
            label: 'Rate',
            value: '৳${profile.hourlyRate.toStringAsFixed(0)}/hr',
          ),
          const SizedBox(height: 16),
          _FactRow(
            icon: Icons.calendar_today,
            label: 'Availability',
            value: profile.availability,
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 24),
          _FactRow(
            icon: Icons.phone,
            label: 'Phone',
            value: profile.phone,
            action: profile.phone.isNotEmpty ? _FactAction.call : null,
          ),
          const SizedBox(height: 16),
          _FactRow(
            icon: Icons.email,
            label: 'Email',
            value: profile.email,
            action: profile.email.isNotEmpty ? _FactAction.email : null,
          ),
          const SizedBox(height: 16),
          _FactRow(
            icon: Icons.location_on,
            label: 'Address',
            value: profile.address,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

enum _FactAction { call, email }

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.action,
    this.maxLines = 1,
  });

  final IconData icon;
  final String label;
  final String value;
  final _FactAction? action;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.outlineLight),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariantLight,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceLight,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                if (action != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    action == _FactAction.call ? Icons.call : Icons.alternate_email,
                    size: 14,
                    color: AppColors.primaryLight,
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}
