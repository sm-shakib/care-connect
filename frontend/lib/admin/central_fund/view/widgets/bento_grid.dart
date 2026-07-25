import 'package:flutter/material.dart';

class BentoGrid extends StatelessWidget {
  const BentoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.25,
      children: [
        // Balance Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2DD4BF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBACAC5)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF00574D), size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Current Fund Balance", style: TextStyle(color: Color(0xCC00574D), fontSize: 13, fontWeight: FontWeight.w600)),
                  Text("৳ 458,200", style: TextStyle(color: Color(0xFF00574D), fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        // Donations Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBACAC5)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.volunteer_activism_outlined, color: Color(0xFF006B5F), size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Donations", style: TextStyle(color: Color(0xFF3C4A46), fontSize: 13, fontWeight: FontWeight.w600)),
                  Text("৳ 1.2M", style: TextStyle(color: Color(0xFF006B5F), fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        // Pending Requests Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBACAC5)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.pending_actions_outlined, color: Color(0xFF4059AA), size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pending Aid", style: TextStyle(color: Color(0xFF3C4A46), fontSize: 13, fontWeight: FontWeight.w600)),
                  Text("12 Cases", style: TextStyle(color: Color(0xFF4059AA), fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        // Aid Distributed Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF77CDC3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBACAC5)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.handshake_outlined, color: Color(0xFF005751), size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Aid Distributed", style: TextStyle(color: Color(0xCC005751), fontSize: 13, fontWeight: FontWeight.w600)),
                  Text("৳ 741,800", style: TextStyle(color: Color(0xFF005751), fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}