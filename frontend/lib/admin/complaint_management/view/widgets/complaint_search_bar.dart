import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Rounded search field for searching complaints by ID or reporter,
/// styled to match the Verification search bar.
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppColors.outlineLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search complaints by ID or reporter...',
                hintStyle: TextStyle(
                  color: AppColors.onSurfaceVariantLight,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          /*GestureDetector(
            onTap: onFilterTap,
            child: Icon(
              Icons.tune,
              color: AppColors.outlineLight,
            ),
          ),*/
        ],
      ),
    );
  }
}