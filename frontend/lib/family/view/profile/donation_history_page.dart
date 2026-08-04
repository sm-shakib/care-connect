import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';

class DonationHistoryPage extends StatelessWidget {
  const DonationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock history
    final history = [
      {'amount': '500', 'date': 'Oct 15, 2023', 'status': 'Successful'},
      {'amount': '1000', 'date': 'Sep 22, 2023', 'status': 'Successful'},
      {'amount': '250', 'date': 'Aug 05, 2023', 'status': 'Successful'},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Donation History'),
        centerTitle: true,
      ),
      body: history.isEmpty
          ? const Center(child: Text('No donations yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  // color: Colors.pink.shade50,
                  color: AppColors.paleMint.withValues(alpha: 0.18),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.outlineVariantLight),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.paleMint,
                      child: Icon(Icons.volunteer_activism, color: AppColors.darkTeal),
                    ),
                    title: Text('৳ ${item['amount']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('Donated on ${item['date']}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['status']!,
                        style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
