import 'package:flutter/material.dart';
import '../../models/central_fund_models.dart';

class BentoGrid extends StatelessWidget {
  final FundStats? stats;
  const BentoGrid({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Top-Left Card: Current Fund Balance
            Expanded(
              child: _BentoCard(
                icon: Icons.account_balance_wallet,
                title: 'Current Fund Balance',
                value: '৳ ${stats?.balance.toStringAsFixed(0) ?? "0"}',
              ),
            ),
            const SizedBox(width: 12),
            // Top-Right Card: Total Donations
            Expanded(
              child: _BentoCard(
                icon: Icons.volunteer_activism,
                title: 'Total Donations',
                value: '৳ ${stats?.totalDonations.toStringAsFixed(0) ?? "0"}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Bottom-Left Card: Pending Aid
            Expanded(
              child: _BentoCard(
                icon: Icons.assignment_late_outlined,
                title: 'Pending Aid',
                value: '${stats?.pendingAidsCount ?? 0} Cases',
              ),
            ),
            const SizedBox(width: 12),
            // Bottom-Right Card: Aid Distributed
            Expanded(
              child: _BentoCard(
                icon: Icons.handshake_outlined,
                title: 'Aid Distributed',
                value: '৳ ${stats?.aidsDistributedAmount.toStringAsFixed(0) ?? "0"}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _BentoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBACAC5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF006B5F), size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF3C4A46),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF006B5F),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
