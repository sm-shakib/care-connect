import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getGreeting(),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.onSurfaceVariantLight,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Manage Your Loved Ones',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceLight,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Monitor your elders anytime, anywhere.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.onSurfaceVariantLight,
          ),
        ),
      ],
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning 👋';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon ☀️';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening 🌙';
    } else {
      return 'Good Night 😴';
    }
  }
}
