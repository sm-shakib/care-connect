import 'package:flutter/material.dart';
import '../../models/central_fund_models.dart';
import './aid_request_review_page.dart';

class AidRequestCard extends StatelessWidget {
  final AidRequestModel request;

  const AidRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final bool isApproved = request.status == "APPROVED";

    // Theme Colors based on your Tailwind config
    const Color surfaceLowest = Color(0xFFFFFFFF);
    const Color outlineVariant = Color(0xFFBACAC5);
    const Color onSurface = Color(0xFF1A1C1C);
    const Color onSurfaceVariant = Color(0xFF3C4A46);
    const Color primary = Color(0xFF006B5F);
    const Color onPrimary = Color(0xFFFFFFFF);
    const Color secondary = Color(0xFF4059AA);

    return Opacity(
      opacity: isApproved ? 0.7 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(20), // Tailwind p-5
        decoration: BoxDecoration(
          color: surfaceLowest,
          borderRadius: BorderRadius.circular(12), // Tailwind rounded-xl
          border: Border.all(color: outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Names and Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requesterName,
                        style: const TextStyle(
                          color: onSurface,
                          fontSize: 16, // label-lg
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        request.requestTitle,
                        style: const TextStyle(
                          color: onSurfaceVariant,
                          fontSize: 14, // label-md
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? primary.withOpacity(0.2) // bg-primary/20
                        : secondary.withOpacity(0.1), // bg-secondary/10
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(
                      color: isApproved ? primary : secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16), // Tailwind space-y-4

            // Note
            Text(
              request.note,
              style: TextStyle(
                color: onSurfaceVariant,
                fontSize: 16, // body-md
                fontStyle: isApproved ? FontStyle.normal : FontStyle.italic,
              ),
            ),

            const SizedBox(height: 16), // Tailwind space-y-4

            // Footer Row: Date/Title and Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // FIX: Wrapped in Flexible to prevent right overflow when text is long
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requested: ${request.date}',
                        style: const TextStyle(
                          color: onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        isApproved ? 'Care Assigned' : 'Caregiver Needed',
                        style: const TextStyle(
                          color: primary,
                          fontSize: 20, // headline-sm
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Action Button
                isApproved
                    ? OutlinedButton(
                  onPressed: null, // Disabled for active/approved
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    minimumSize: const Size(0, 48), // h-touch-target-min
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AidRequestReviewPage(request: request),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    minimumSize: const Size(0, 48), // h-touch-target-min
                  ),
                  child: const Text(
                    'Review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}