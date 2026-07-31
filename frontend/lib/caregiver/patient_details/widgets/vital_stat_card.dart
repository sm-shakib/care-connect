import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';

class VitalStatCard extends StatelessWidget {
  const VitalStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.valueWidget,
    required this.lastCheckedText,
    required this.buttonLabel,
    required this.onButtonTap,
    //this.statusLabel,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget valueWidget;
  final String lastCheckedText;
  final String buttonLabel;
  final VoidCallback onButtonTap;
  //final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 170),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,  //
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //Icon(icon, size: 20, color: iconColor),
                  Icon(icon, size: 20, color: AppColors.darkTeal),
                  const SizedBox(width: 8),
                  Flexible(
                    fit: FlexFit.loose,  //
                    child: Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              // if (statusLabel != null)
              //   Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //     decoration: BoxDecoration(
              //       //color: colorScheme.primaryContainer.withValues(alpha: 0.2),
              //       color: AppColors.darkTeal,
              //       borderRadius: BorderRadius.circular(6),
              //     ),
              //     child: Text(
              //       statusLabel!,
              //       style: TextStyle(
              //         fontSize: 11,
              //         fontWeight: FontWeight.w800,
              //         color: colorScheme.primary,
              //       ),
              //     ),
              //   ),
            ],
          ),
          const SizedBox(height: 10),
          valueWidget,
          const SizedBox(height: 4),
          Text(
            lastCheckedText,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          // SizedBox(
          //   width: double.infinity,
          //   height: 44,
          //   child: ElevatedButton.icon(
          //     onPressed: onButtonTap,
          //     icon: const Icon(Icons.add_box, size: 18),
          //     label: Text(
          //       buttonLabel,
          //       style: const TextStyle(fontWeight: FontWeight.bold),
          //     ),
          //     style: ElevatedButton.styleFrom(
          //       //backgroundColor: colorScheme.primary,
          //       backgroundColor: AppColors.darkTeal,
          //       foregroundColor: colorScheme.onPrimary,
          //       elevation: 0,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(25),
          //       ),
          //     ),
          //   ),
          // ),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onButtonTap,
              icon: const Icon(Icons.add_box, size: 18),
              label: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFBFEFC),
                foregroundColor: AppColors.darkTeal,
                side: const BorderSide(
                  color: AppColors.darkTeal,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}