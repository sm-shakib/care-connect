import 'package:flutter/material.dart';
import '../../models/central_fund_models.dart';

class AidRequestCard extends StatelessWidget {
  final AidRequestModel request;

  const AidRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final bool isApproved = request.status == "APPROVED";

    return Opacity(
      opacity: isApproved ? 0.7 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBACAC5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.requesterName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(request.requestTitle, style: const TextStyle(color: Color(0xFF3C4A46), fontSize: 14)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isApproved ? const Color(0xFF006B5F).withOpacity(0.2) : const Color(0xFF4059AA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(
                      color: isApproved ? const Color(0xFF006B5F) : const Color(0xFF4059AA),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(request.note, style: TextStyle(color: const Color(0xFF3C4A46), fontStyle: isApproved ? FontStyle.normal : FontStyle.italic)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Requested: ${request.date}', style: const TextStyle(color: Color(0xFF3C4A46), fontSize: 12)),
                    Text(request.amount, style: const TextStyle(color: Color(0xFF006B5F), fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                isApproved
                    ? OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF006B5F), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Disbursed', style: TextStyle(color: Color(0xFF006B5F), fontWeight: FontWeight.bold)),
                )
                    : ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B5F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Review', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}