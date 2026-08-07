import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';

class ElderlyNotificationsPage extends StatelessWidget {
  const ElderlyNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications for the elder
    final notifications = [
      {
        'title': 'Medicine Reminder',
        'body': "It's time to take your Metformin (500mg).",
        'time': '10 min ago',
        'icon': Icons.medication,
        'color': AppColors.primaryLight,
      },
      {
        'title': 'Appointment Reminder',
        'body': '3 days left for your appointment with Dr. Ariful Islam.',
        'time': '1 hour ago',
        'icon': Icons.calendar_month,
        'color': Colors.blue,
      },
      {
        'title': 'New Family Request',
        'body': 'A family member has sent you a binding request.',
        'time': '2 hours ago',
        'icon': Icons.people_alt_rounded,
        'color': AppColors.darkTeal,
      },
      {
        'title': 'Caregiver Message',
        'body': 'Your caregiver sent you a new message.',
        'time': '5 hours ago',
        'icon': Icons.chat_bubble,
        'color': Colors.green,
      },
      {
        'title': 'Medicine Taken',
        'body': 'You marked Amlodipine (5mg) as taken at 08:00 AM.',
        'time': '1 day ago',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFBFEFC),
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(color: AppColors.outlineVariantLight),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.darkTeal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            color: AppColors.paleMint.withValues(alpha: 0.18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.outlineVariantLight),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (item['color'] as Color).withOpacity(0.1),
                child: Icon(item['icon'] as IconData, color: item['color'] as Color),
              ),
              title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(item['body'] as String),
                  const SizedBox(height: 4),
                  Text(item['time'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
