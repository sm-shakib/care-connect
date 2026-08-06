import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Sticky bottom bar with the two primary complaint actions.
class ComplaintActionsBar extends StatelessWidget {
  const ComplaintActionsBar({
    required this.isResolved,
    required this.onResolve,
    super.key,
  });

  final bool isResolved;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariantLight),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isResolved ? null : onResolve,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.onPrimaryLight,
                    disabledBackgroundColor:
                    AppColors.surfaceContainerHighLight,
                    disabledForegroundColor:
                    AppColors.onSurfaceVariantLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.task_alt),
                  label: Text(
                    isResolved ? 'Complaint Resolved' : 'Resolve Complaint',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}