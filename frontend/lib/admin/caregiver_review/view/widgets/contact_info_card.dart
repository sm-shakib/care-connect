import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_application_model.dart';

/// Material-3-style ListTile card for phone / email / address.
class ContactInfoCard extends StatelessWidget {
  const ContactInfoCard({required this.application, super.key});

  final CaregiverApplication application;

  Future<void> _launchDialer(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _launchMap(String address) async {
    final query = Uri.encodeComponent(address);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        icon: Icons.call,
        label: 'Phone',
        value: application.phone,
        onTap: () => _launchDialer(application.phone)
      ),
      (
        icon: Icons.mail,
        label: 'Email',
        value: application.email,
        onTap: () => _launchEmail(application.email)
      ),
      (
        icon: Icons.location_on,
        label: 'Address',
        value: application.address,
        onTap: () => _launchMap(application.address)
      ),
    ];

    return Container(
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
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  height: 1,
                  color: AppColors.outlineVariantLight,
                ),
              ),
            _ContactRow(
              icon: rows[i].icon,
              label: rows[i].label,
              value: rows[i].value,
              onTap: rows[i].onTap,
              // Match top/bottom radius to container
              borderRadius: i == 0
                  ? const BorderRadius.vertical(top: Radius.circular(20))
                  : i == rows.length - 1
                      ? const BorderRadius.vertical(bottom: Radius.circular(20))
                      : null,
            ),
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
    required this.onTap,
    this.borderRadius,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryLight),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariantLight,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
