import 'package:flutter/material.dart';
import 'package:frontend/core/donation/view/donation_flow_page.dart';
import 'package:frontend/core/donation/view/donation_history_page.dart';
import 'package:frontend/elderly/view/assistance_form_page.dart';
import 'package:frontend/elderly/view/assistance_history_page.dart';
import 'package:frontend/theme/app_colors.dart';

class DonationAssistancePage extends StatelessWidget {
  const DonationAssistancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFEFC),
        title: const Text('Donation & Assistance'),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkTeal),
      ),
      body: SingleChildScrollView(
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
            const SizedBox(height: 20),
            _DonationHistoryRow(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DonationHistoryPage()),
              ),
            ),
            const SizedBox(height: 20),
            _AssistanceCard(
              onApply: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AssistanceFormPage()),
              ),
            ),
            const SizedBox(height: 20),
            _AssistanceHistoryRow(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AssistanceHistoryPage()),
              ),
            ),
          ],
        ),
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
          const Icon(Icons.volunteer_activism,
              size: 56, color: AppColors.darkTeal),
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
          const Text(
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

class _AssistanceCard extends StatelessWidget {
  const _AssistanceCard({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.volunteer_activism_outlined,
              size: 56, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Apply for Assistance',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'In need of a specialized caregiver but facing financial constraints? '
            'Apply for assistance through our central fund.',
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
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Apply Now',
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
          child: const Row(
            children: [
              Icon(Icons.history, color: AppColors.darkTeal),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Donation History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTeal,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.darkTeal),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistanceHistoryRow extends StatelessWidget {
  const _AssistanceHistoryRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: const Row(
            children: [
              Icon(Icons.history_edu, color: Colors.blue),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Assistance History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
