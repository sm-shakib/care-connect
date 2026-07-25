import 'package:flutter/material.dart';
import '../../models/central_fund_models.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;

  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconBg;
    Color iconColor;
    Color amountColor;

    switch (tx.type) {
      case TransactionType.disbursement:
        icon = Icons.remove;
        iconBg = const Color(0xFFFFDAD6);
        iconColor = const Color(0xFFBA1A1A);
        amountColor = const Color(0xFFBA1A1A);
        break;
      case TransactionType.donation:
        icon = Icons.add;
        iconBg = const Color(0xFF2DD4BF);
        iconColor = const Color(0xFF00574D);
        amountColor = const Color(0xFF006B5F);
        break;
      case TransactionType.sync:
        icon = Icons.sync;
        iconBg = const Color(0xFFEEEEEE);
        iconColor = const Color(0xFF6B7A76);
        amountColor = const Color(0xFF1A1C1C);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBACAC5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconBg,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(tx.subtitle, style: const TextStyle(color: Color(0xFF3C4A46), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(tx.amount, style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                tx.status,
                style: TextStyle(
                  color: tx.type == TransactionType.sync ? const Color(0xFF4059AA) : const Color(0xFF3C4A46),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}