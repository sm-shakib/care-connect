import 'package:flutter/material.dart';
import 'package:frontend/admin/central_fund/models/central_fund_models.dart';
import 'package:frontend/admin/central_fund/view/widgets/aid_request_review_page.dart';

class AidRequestCard extends StatelessWidget {
  const AidRequestCard({
    required this.request,
    super.key,
  });

  final AidRequestModel request;

  /// What this request is waiting on, from the admin's point of view.
  String get _headline {
    if (request.status == 'awaiting_caregiver') {
      final name = request.assignedCaregiverName ?? 'caregiver';
      return 'Awaiting $name';
    }
    if (request.status == 'approved' || request.status == 'disbursed') {
      return 'Aid Processed';
    }
    return 'Caregiver Needed';
  }

  @override
  Widget build(BuildContext context) {
    // Offered to a caregiver who hasn't answered yet. Not actionable by
    // the admin — reallocating now would double-book the request — but
    // not finished either, so it reads differently from both.
    final isAwaitingCaregiver = request.status == 'awaiting_caregiver';
    final isApproved =
        request.status == 'approved' || request.status == 'disbursed';
    final isSettled = isApproved || isAwaitingCaregiver;

    const surfaceLowest = Color(0xFFFFFFFF);
    const outlineVariant = Color(0xFFBACAC5);
    const onSurface = Color(0xFF1A1C1C);
    const onSurfaceVariant = Color(0xFF3C4A46);
    const primary = Color(0xFF006B5F);
    const onPrimary = Color(0xFFFFFFFF);
    const secondary = Color(0xFF4059AA);

    return Opacity(
      opacity: isApproved ? 0.7 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? primary.withValues(alpha: 0.2)
                        : secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    isAwaitingCaregiver
                        ? 'AWAITING CAREGIVER'
                        : request.status.toUpperCase(),
                    style: TextStyle(
                      color: isApproved ? primary : secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              request.reason,
              style: TextStyle(
                color: onSurfaceVariant,
                fontSize: 16,
                fontStyle: isApproved ? FontStyle.normal : FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requested: ${request.date.split('T')[0]}',
                        style: const TextStyle(
                          color: onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _headline,
                        style: const TextStyle(
                          color: primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isSettled)
                  OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text(
                      isAwaitingCaregiver ? 'Sent' : 'Active',
                      style: const TextStyle(
                        color: primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AidRequestReviewPage(request: request),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      minimumSize: const Size(0, 48),
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
