import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';

class FamilyNotificationsPage extends StatelessWidget {
  const FamilyNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications for ALL elders
    final notifications = [
      {
        'title': 'Medicine Taken',
        'body': 'Abdul Karim has taken Metformin (500mg) at 08:00 AM.',
        'time': '10 min ago',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'Appointment Reminder',
        'body': '3 days left for Abdul Karim\'s appointment with Dr. Ariful Islam.',
        'time': '1 hour ago',
        'icon': Icons.calendar_month,
        'color': AppColors.primaryLight,
      },
       {
        'title': 'High Heart Rate Alert',
        'body': 'Rahima Begum\'s heart rate was 105 bpm (High) at 02:30 PM.',
        'time': '3 hours ago',
        'icon': Icons.favorite,
        'color': AppColors.warningRed,
      },
      {
        'title': 'Location Update',
        'body': 'Abdul Karim has arrived at City Hospital, Dhaka.',
        'time': '5 hours ago',
        'icon': Icons.location_on,
        'color': Colors.blue,
      },
      {
        'title': 'New Request Accepted',
        'body': 'Michael Chen has accepted the caregiving request for Rahima Begum.',
        'time': '1 day ago',
        'icon': Icons.person_add,
        'color': AppColors.darkTeal,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final item = notifications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
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
    );
  }
}
