import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';

import '../models/patient.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({super.key, required this.patient, this.onTap});

  final Patient patient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bannerColor = patient.isUrgent ? colorScheme.error : colorScheme.tertiary;
    final bannerBackground = patient.isUrgent
        ? colorScheme.errorContainer.withValues(alpha: 0.4)
        : colorScheme.tertiaryContainer.withValues(alpha: 0.25);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.paleMint,
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: AppColors.darkTeal,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${patient.age} years • ${patient.location}',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.outlineVariant),
              ],
            ),
            // const SizedBox(height: 14),
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            //   decoration: BoxDecoration(
            //     color: bannerBackground,
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   // child: Row(
            //   //   children: [
            //   //     Icon(patient.conditionIcon, size: 20, color: bannerColor),
            //   //     const SizedBox(width: 10),
            //   //     Expanded(
            //   //       child: Text(
            //   //         patient.conditionLabel,
            //   //         style: TextStyle(
            //   //           fontSize: 14,
            //   //           color: colorScheme.onSurface,
            //   //         ),
            //   //       ),
            //   //     ),
            //   //   ],
            //   // ),
            // ),
          ],
        ),
      ),
    );
  }
}