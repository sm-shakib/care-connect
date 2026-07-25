import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';

class NotificationsTopBar extends StatelessWidget {
  const NotificationsTopBar({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            //icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            icon: Icon(Icons.arrow_back, color: AppColors.darkTeal),
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              //color: colorScheme.primary,
              color: AppColors.darkTeal,
            ),
          ),
        ],
      ),
    );
  }
}