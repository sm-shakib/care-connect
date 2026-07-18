import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/complaint_filter.dart';

/// Horizontally scrolling row of status filter chips.
class ComplaintFilterChips extends StatelessWidget {
  const ComplaintFilterChips({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final ComplaintFilter selected;
  final ValueChanged<ComplaintFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ComplaintFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = ComplaintFilter.values[index];
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight
              : AppColors.surfaceContainerLight,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(color: AppColors.outlineVariantLight),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? AppColors.onPrimaryLight
                : AppColors.onSurfaceVariantLight,
          ),
        ),
      ),
    );
  }
}