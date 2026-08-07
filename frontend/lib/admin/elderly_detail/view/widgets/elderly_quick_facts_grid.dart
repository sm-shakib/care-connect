import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/elderly_profile_model.dart';

/// Single-card list of quick facts (Gender, Age, Phone, Email, Address),
/// styled to match [CaregiverContactCard].
class ElderlyQuickFactsGrid extends StatelessWidget {
  const ElderlyQuickFactsGrid({
    required this.profile,
    this.onViewOnMap,
    super.key,
  });

  final ElderlyProfile profile;
  final VoidCallback? onViewOnMap;

  Future<void> _launchDialer(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    try {
      await launchUrl(uri);
    } catch (e) {
      // Handle error or show snackbar
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Fallback if mailto fails
    }
  }

  Future<void> _launchMap(String address) async {
    final query = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 16),
          _FactRow(
            icon: profile.gender.toLowerCase() == 'female'
                ? Icons.female
                : Icons.male,
            label: 'Gender',
            value: profile.gender,
          ),
          const SizedBox(height: 16),
          _FactRow(icon: Icons.cake, label: 'Age', value: '${profile.age} Years'),
          const SizedBox(height: 16),
          _FactRow(
            icon: Icons.call,
            label: 'Phone',
            value: profile.phone,
            onTap: () => _launchDialer(profile.phone),
          ),
          const SizedBox(height: 16),
          _FactRow(
            icon: Icons.mail,
            label: 'Email',
            value: profile.email,
            onTap: () => _launchEmail(profile.email),
          ),
          const SizedBox(height: 16),
          _FactRow(
            icon: Icons.location_on,
            label: 'Home Address',
            value: profile.address,
            action: InkWell(
              onTap: onViewOnMap ?? () => _launchMap(profile.address),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View on Map',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.open_in_new,
                      size: 14,
                      color: AppColors.primaryLight,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.action,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.onSurfaceLight,
                    ),
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

