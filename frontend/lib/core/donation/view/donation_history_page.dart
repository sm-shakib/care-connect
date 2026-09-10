import 'package:flutter/material.dart';
import 'package:frontend/core/donation/data/donation_repository.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:intl/intl.dart';

class DonationHistoryPage extends StatelessWidget {
  const DonationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Donation History'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DonationRepository().getMyDonationHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return const Center(child: Text('No donations yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final date = DateTime.parse(item['created_at'] as String);
              final dateStr = DateFormat('MMM d, yyyy').format(date);
              final amount = item['amount'];
              final method = item['payment_method'];
              final status = item['payment_status'];

              return Card(
                color: AppColors.paleMint.withValues(alpha: 0.25),
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.outlineVariantLight),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.paleMint,
                    child: Icon(Icons.volunteer_activism, color: AppColors.darkTeal),
                  ),
                  title: Text('৳ $amount',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('Via ${method.toString().toUpperCase()} on $dateStr'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == 'completed' ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.toString().toUpperCase(),
                      style: TextStyle(
                        color: status == 'completed' ? Colors.green : Colors.orange, 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
