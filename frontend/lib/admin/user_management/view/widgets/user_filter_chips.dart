import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/user_management_filter.dart';

/// Horizontally scrolling row of filter chips. The selected chip uses the
/// primary fill; unselected chips use the neutral high-surface fill.
class UserFilterChips extends StatelessWidget {
  const UserFilterChips({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final UserManagementFilter selected;
  final ValueChanged<UserManagementFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = UserManagementFilter.values
        .where((f) => f != UserManagementFilter.admin)
        .toList();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selected;
          return _FilterChip(
            label: filter.label,
            isSelected: isSelected,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight
              : AppColors.surfaceContainerHighLight,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check,
                size: 18,
                color: AppColors.onPrimaryLight,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.onPrimaryLight
                    : AppColors.onSurfaceVariantLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}