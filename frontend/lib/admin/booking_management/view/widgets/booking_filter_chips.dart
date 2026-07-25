import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/booking_filter.dart';

/// Horizontally scrolling row of booking-status filter chips. Pill
/// shaped (fully rounded), matching this screen's design — the other
/// admin list screens use rounded-lg (8px) chips instead.
class BookingFilterChips extends StatelessWidget {
  const BookingFilterChips({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final BookingFilter selected;
  final ValueChanged<BookingFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: BookingFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = BookingFilter.values[index];
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
          borderRadius: BorderRadius.circular(999),
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