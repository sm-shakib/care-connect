import 'package:flutter/material.dart';
import 'package:frontend/core/donation/view/donation_flow_page.dart';
import 'package:frontend/core/donation/view/donation_history_page.dart';
import 'package:frontend/theme/app_colors.dart';

/// Donation landing content for the family's Donation tab.
class FamilyDonationTab extends StatelessWidget {
  const FamilyDonationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CentralFundCard(
            onDonate: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DonationFlowPage()),
            ),
          ),
          const SizedBox(height: 16),
          _DonationHistoryRow(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DonationHistoryPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _CentralFundCard extends StatelessWidget {
  const _CentralFundCard({required this.onDonate});

  final VoidCallback onDonate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.paleMint,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Icon(Icons.volunteer_activism, size: 56, color: AppColors.darkTeal),
          const SizedBox(height: 16),
          const Text(
            'CareConnect Central Fund',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTeal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Support elders who cannot afford caregiving services. '
                'Your contribution makes a difference.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.onSurfaceVariantLight,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onDonate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkTeal,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Donate Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationHistoryRow extends StatelessWidget {
  const _DonationHistoryRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paleMint.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.paleMint),
          ),
          child: Row(
            children: [
              const Icon(Icons.history, color: AppColors.darkTeal),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Donation History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTeal,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.darkTeal),
            ],
          ),
        ),
      ),
    );
  }
}
