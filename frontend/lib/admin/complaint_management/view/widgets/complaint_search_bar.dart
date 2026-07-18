import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Rounded search field for searching complaints by ID or reporter name.
class ComplaintSearchBar extends StatelessWidget {
  const ComplaintSearchBar({
    required this.onChanged,
    this.onFilterTap,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariantLight, width: 2),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: AppColors.outlineLight),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search complaints by ID or reporter',
                hintStyle: TextStyle(
                  color: AppColors.onSurfaceVariantLight,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onFilterTap,
            icon:
            Icon(Icons.filter_list, color: AppColors.onSurfaceVariantLight),
          ),
        ],
      ),
    );
  }
}