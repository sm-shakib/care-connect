import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';

class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({
    required this.totalElders,
    required this.totalCaregivers,
    super.key,
  });

  final int totalElders;
  final int totalCaregivers;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _showStatsDialog(context, 'Elders', 'You are currently managing $totalElders loved ones in your family account.'),
            borderRadius: BorderRadius.circular(20),
            child: _StatCard(
              icon: Icons.people,
              title: 'Elders',
              value: totalElders.toString(),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: InkWell(
            onTap: () => _showStatsDialog(context, 'Caregivers', 'There are $totalCaregivers active caregivers providing care to your elders.'),
            borderRadius: BorderRadius.circular(20),
            child: _StatCard(
              icon: Icons.medical_services,
              title: 'Caregivers',
              value: totalCaregivers.toString(),
            ),
          ),
        ),
      ],
    );
  }

  void _showStatsDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(color: AppColors.darkTeal, fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.darkTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      // child: Padding(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primaryLight,
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceLight,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.onSurfaceVariantLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
