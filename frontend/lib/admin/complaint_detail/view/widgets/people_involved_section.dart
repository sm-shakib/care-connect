import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/complaint_detail_model.dart';

/// Two side-by-side cards for the reporter and the person the complaint
/// is against, each with an avatar, name, and role.
class PeopleInvolvedSection extends StatelessWidget {
  const PeopleInvolvedSection({
    required this.reporter,
    required this.against,
    this.onReporterTap,
    this.onAgainstTap,
    super.key,
  });

  final Person reporter;
  final Person against;
  final VoidCallback? onReporterTap;
  final VoidCallback? onAgainstTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _PersonCard(
            label: 'Reporter',
            person: reporter,
            ringColor: AppColors.primaryContainerLight,
            onTap: onReporterTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PersonCard(
            label: 'Against',
            person: against,
            ringColor: AppColors.errorContainerLight,
            onTap: onAgainstTap,
          ),
        ),
      ],
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.label,
    required this.person,
    required this.ringColor,
    this.onTap,
  });

  final String label;
  final Person person;
  final Color ringColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariantLight,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ringColor, width: 2),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: Image.network(
                      person.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceContainerHighLight,
                        child:
                            const Icon(Icons.person, color: AppColors.outlineLight),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                person.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceLight,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                person.role,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.outlineLight),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}