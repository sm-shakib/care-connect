import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Sticky bottom bar with two side-by-side pill buttons: "Support"
/// (outlined) and "Modify" (filled) — kept as-is from the original
/// design. Unlike the "Contact Support" button dropped from the
/// booking *list* cards (a user-facing action that didn't make sense
/// for admins), this one reads more like an admin escalation/support
/// action on a specific booking, so it was kept rather than removed.
/// Flag if you'd rather this be renamed/dropped too, for consistency
/// with that earlier decision.
class BookingDetailActionsBar extends StatelessWidget {
  const BookingDetailActionsBar({
    this.onSupport,
    this.onModify,
    super.key,
  });

  final VoidCallback? onSupport;
  final VoidCallback? onModify;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariantLight),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -1),
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
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: onSupport,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceLight,
                          side: BorderSide(color: AppColors.outlineLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        icon: const Icon(Icons.support_agent),
                        label: const Text(
                          'Support',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: onModify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.onPrimaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text(
                          'Modify',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
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