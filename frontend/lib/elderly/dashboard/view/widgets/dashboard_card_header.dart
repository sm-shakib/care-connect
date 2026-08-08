import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

class DashboardCardHeader extends StatelessWidget {
  const DashboardCardHeader({
    required this.icon,
    required this.title,
    this.trailingLabel,
    this.onTrailingTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 26),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        if (trailingLabel != null)
          TextButton(
            onPressed: onTrailingTap,
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: Text(
              trailingLabel!,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
