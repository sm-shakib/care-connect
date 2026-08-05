import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Sticky bottom bar with the two admin actions. Pill-shaped buttons,
/// matching Elderly Profile and Family Member Profile's action bars.
class CaregiverActionsBar extends StatelessWidget {
  const CaregiverActionsBar({
    required this.isSuspended,
    required this.onToggleStatus,
    required this.onRemove,
    super.key,
  });

  final bool isSuspended;
  final VoidCallback onToggleStatus;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariantLight),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: onToggleStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: AppColors.onPrimaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      icon: Icon(isSuspended ? Icons.check_circle : Icons.block),
                      label: Text(
                        isSuspended ? 'Reactivate Account' : 'Suspend Account',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: onRemove,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorLight,
                        side: BorderSide(color: AppColors.errorLight, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text(
                        'Remove User',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}