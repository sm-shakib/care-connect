import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_profile_model.dart';

/// "Contact Details" card: phone, email, address rows. Header is
/// uppercase + primary-colored (matching this design's address-card
/// style elsewhere in the app), and icon circles are primary-tinted.
class CaregiverContactCard extends StatelessWidget {
  const CaregiverContactCard({required this.profile, super.key});

  final CaregiverProfile profile;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.phone, 'Phone', profile.phone),
      (Icons.mail, 'Email', profile.email),
      (Icons.location_on, 'Address', profile.address),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_page, color: AppColors.primaryLight),
              const SizedBox(width: 12),
              Text(
                'CONTACT DETAILS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _ContactRow(icon: rows[i].$1, label: rows[i].$2, value: rows[i].$3),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryContainerLight.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryLight),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariantLight,
                ),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16, color: AppColors.onSurfaceLight),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}