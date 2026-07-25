import 'package:flutter/material.dart';
import '../../models/central_fund_models.dart';

class DonationTile extends StatelessWidget {
  final DonationModel donation;

  const DonationTile({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBACAC5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(donation.imageUrl),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(donation.donorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('${donation.date} • ${donation.paymentMethod}', style: const TextStyle(color: Color(0xFF3C4A46), fontSize: 12)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(donation.amount, style: const TextStyle(color: Color(0xFF006B5F), fontWeight: FontWeight.bold, fontSize: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal:8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF006B5F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('SUCCESS', style: TextStyle(color: Color(0xFF006B5F), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}