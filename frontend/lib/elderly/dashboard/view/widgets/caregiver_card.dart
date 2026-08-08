import 'package:flutter/material.dart';
import 'package:frontend/caregiver/caregiver_details/view/caregiver_details_page.dart';
import 'package:frontend/caregiver/data/caregiver_dummy_data.dart';
import 'package:frontend/shared/chat/chat.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/dashboard_models.dart';
import 'dashboard_card_header.dart';

/// Card showing the elderly user's assigned caregiver with a quick action
/// to message them. Tapping the card opens the caregiver's full details,
/// matching the family user's assigned-caregiver flow.
class CaregiverCard extends StatelessWidget {
  const CaregiverCard({
    required this.caregiver,
    super.key,
  });

  final CaregiverSummary? caregiver;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: caregiver == null ? null : () => _openCaregiverDetails(context),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
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
                _CaregiverDetails(caregiver: caregiver!),
            ],
          ),
        ),
      ),
    );
  }

  void _openCaregiverDetails(BuildContext context) {
    // Look up the full caregiver profile to show on the details page, the
    // same way the family user's assigned-caregiver card does.
    final fullCaregiver = caregiverList.firstWhere(
      (c) => c.name == caregiver!.name,
      orElse: () => caregiverList.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CaregiverDetailsPage(
          caregiver: fullCaregiver,
          isAssigned: true,
        ),
      ),
    );
  }
}

class _CaregiverDetails extends StatelessWidget {
  const _CaregiverDetails({required this.caregiver});

  final CaregiverSummary caregiver;

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
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    caregiver.profession,
                    style: TextStyle(
                      fontSize: 15,
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
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _openConversation(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.chat_bubble_outline, size: 20),
            label: const Text(
              'Message',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join();
    return letters.toUpperCase();
  }

  Future<void> _openConversation(BuildContext context) async {
    // Open (or start) a direct conversation with this caregiver, the same
    // way the family user's "Chat" action does from monitoring.
    final repository = MockChatRepository.instance;
    final contact = ChatDirectory.resolveOrCreateContact(
      caregiver.name,
      role: ChatRole.caregiver,
    );
    final conversation = await repository.createDirectConversation(
      currentUser: ChatDirectory.adib,
      other: contact,
    );
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ConversationPage(
          repository: repository,
          conversationId: conversation.id,
          currentUser: ChatDirectory.adib,
        ),
      ),
    );
  }
}
