import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/central_fund/cubit/central_fund_cubit.dart';
import 'package:frontend/admin/central_fund/models/central_fund_models.dart';
import 'package:frontend/admin/central_fund/view/widgets/aid_request_review_page.dart';

class AidRequestCard extends StatelessWidget {
  const AidRequestCard({
    required this.request,
    super.key,
  });

  final AidRequestModel request;

  @override
  Widget build(BuildContext context) {
    final isApproved =
        request.status == 'approved' || request.status == 'disbursed';
    final isRejected = request.status == 'rejected';

    const surfaceLowest = Color(0xFFFFFFFF);
    const outlineVariant = Color(0xFFBACAC5);
    const onSurface = Color(0xFF1A1C1C);
    const onSurfaceVariant = Color(0xFF3C4A46);
    const primary = Color(0xFF006B5F);
    const onPrimary = Color(0xFFFFFFFF);
    const secondary = Color(0xFF4059AA);
    const error = Color(0xFFBA1A1A);

    return Opacity(
      opacity: (isApproved || isRejected) ? 0.7 : 1.0,
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
                        : isRejected
                            ? error.withValues(alpha: 0.1)
                            : secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      color: isApproved ? primary : isRejected ? error : secondary,
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
                        isApproved
                            ? 'Aid Processed'
                            : isRejected
                                ? 'Request Declined'
                                : 'Caregiver Needed',
                        style: TextStyle(
                          color: isRejected ? error : primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isApproved)
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
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isRejected)
                  OutlinedButton.icon(
                    onPressed: () => _confirmAndDelete(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: error,
                      side: const BorderSide(color: error, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text(
                      'Remove',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Future<void> _confirmAndDelete(BuildContext context) async {
    final cubit = context.read<CentralFundCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove request?'),
        content: const Text(
          'This declined assistance request will be permanently removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove', style: TextStyle(color: Color(0xFFBA1A1A))),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await cubit.deleteAidRequest(request.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove request: $e')),
        );
      }
    }
  }
}
