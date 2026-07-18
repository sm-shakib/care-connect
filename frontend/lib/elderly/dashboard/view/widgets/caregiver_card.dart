import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/dashboard_models.dart';
import 'dashboard_card_header.dart';

/// Card showing the elderly user's assigned caregiver and quick actions
/// to call or message them.
class CaregiverCard extends StatelessWidget {
  const CaregiverCard({
    required this.caregiver,
    this.onCall,
    this.onMessage,
    super.key,
  });

  final CaregiverSummary? caregiver;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardCardHeader(
            icon: Icons.favorite_outline,
            title: 'Your Caregiver',
          ),
          const SizedBox(height: 14),
          if (caregiver == null)
            Text(
              'No caregiver assigned yet.',
              style: TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant),
            )
          else
            _CaregiverDetails(
              caregiver: caregiver!,
              onCall: onCall,
              onMessage: onMessage,
            ),
        ],
      ),
    );
  }
}

class _CaregiverDetails extends StatelessWidget {
  const _CaregiverDetails({
    required this.caregiver,
    this.onCall,
    this.onMessage,
  });

  final CaregiverSummary caregiver;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryContainerLight,
              child: Text(
                _initialsOf(caregiver.name),
                style: const TextStyle(
                  color: AppColors.onPrimaryContainerLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caregiver.name,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    caregiver.profession,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Next visit: ${caregiver.nextVisitLabel}',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call_outlined, size: 20),
                  label: const Text(
                    'Call',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  label: const Text(
                    'Message',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join();
    return letters.toUpperCase();
  }
}
