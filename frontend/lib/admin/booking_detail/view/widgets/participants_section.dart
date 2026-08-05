import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/booking_detail_model.dart';

/// "Participants" section: one card each for the care recipient and
/// the caregiver, each with a contextual action button (call / chat).
class ParticipantsSection extends StatelessWidget {
  const ParticipantsSection({
    required this.careRecipient,
    required this.caregiver,
    this.onCallRecipient,
    this.onChatCaregiver,
    super.key,
  });

  final BookingParticipant careRecipient;
  final BookingParticipant caregiver;
  final VoidCallback? onCallRecipient;
  final VoidCallback? onChatCaregiver;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Participants',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceLight,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _ParticipantCard(
          participant: careRecipient,
          actionIcon: Icons.call,
          onAction: onCallRecipient,
        ),
        const SizedBox(height: 12),
        _ParticipantCard(
          participant: caregiver,
          actionIcon: Icons.call,
          onAction: onChatCaregiver,
        ),
      ],
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({
    required this.participant,
    required this.actionIcon,
    this.onAction,
  });

  final BookingParticipant participant;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 60,
              height: 60,
              child: Image.network(
                participant.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceContainerHighLight,
                  child: Icon(Icons.person, color: AppColors.outlineLight),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.role,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryLight,
                  ),
                ),
                Text(
                  participant.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            height: 48,
            child: OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: AppColors.onSurfaceLight,
                side: BorderSide(color: AppColors.outlineVariantLight),
                shape: const CircleBorder(),
                backgroundColor: AppColors.surfaceContainerLight,
              ),
              child: Icon(actionIcon),
            ),
          ),
        ],
      ),
    );
  }
}