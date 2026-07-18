import 'package:flutter/material.dart';

class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({
    super.key,
    required this.totalElders,
    required this.totalCaregivers,
  });

  final int totalElders;
  final int totalCaregivers;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        Expanded(
          child: _StatCard(
            icon: Icons.people,
            title: "Elders",
            value: totalElders.toString(),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _StatCard(
            icon: Icons.medical_services,
            title: "Caregivers",
            value: totalCaregivers.toString(),
          ),
        ),

      ],
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
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),
        child: Column(
          children: [

            Icon(
              icon,
              color: Colors.teal,
              size: 34,
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

          ],
        ),
      ),
    );
  }
}