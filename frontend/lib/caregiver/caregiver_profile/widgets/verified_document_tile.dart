import 'package:flutter/material.dart';

import 'package:frontend/caregiver_signup/caregiver_signup.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/theme/app_colors.dart';

IconData _iconForDocumentType(CaregiverDocumentType type) {
  switch (type) {
    case CaregiverDocumentType.nationalId:
      return Icons.fingerprint;
    case CaregiverDocumentType.certificate:
      return Icons.medical_services_outlined;
    case CaregiverDocumentType.policeClearance:
      return Icons.badge_outlined;
  }
}

class VerifiedDocumentTile extends StatelessWidget {
  const VerifiedDocumentTile({
    super.key,
    required this.type,
    required this.fileName,
    this.onView,
  });

  final CaregiverDocumentType type;
  final String fileName;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Icon(_iconForDocumentType(type), color: AppColors.darkTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label(context),
                  style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 12, color: AppColors.darkTeal),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.verifiedStatusLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                        //color: colorScheme.tertiary,
                        color: AppColors.darkTeal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.visibility_outlined, color: colorScheme.onSurfaceVariant),
            onPressed: onView,
          ),
        ],
      ),
    );
  }
}