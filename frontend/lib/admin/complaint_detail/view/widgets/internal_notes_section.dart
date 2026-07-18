import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/complaint_detail_model.dart';

/// List of internal admin notes logged against this complaint. The
/// original design had an empty "Timeline" placeholder comment with no
/// content — this fills that gap with a proper notes list, populated
/// via the "Add Internal Note" bottom sheet.
class InternalNotesSection extends StatelessWidget {
  const InternalNotesSection({required this.notes, super.key});

  final List<InternalNote> notes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Internal Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${notes.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariantLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (notes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariantLight),
            ),
            child: Text(
              'No internal notes yet. Notes you add here are only '
                  'visible to admins, not to the reporter or the caregiver.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariantLight,
              ),
            ),
          )
        else
          Column(
            children: [
              for (final note in notes) ...[
                _NoteCard(note: note),
                if (note != notes.last) const SizedBox(height: 8),
              ],
            ],
          ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final InternalNote note;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDateTime(DateTime date) {
    final hour24 = date.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '${_months[date.month - 1]} ${date.day}, ${date.year} • '
        '$hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariantLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 16,
                color: AppColors.tertiaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                note.authorName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceLight,
                ),
              ),
              const Spacer(),
              Text(
                _formatDateTime(note.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariantLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            note.note,
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceLight),
          ),
        ],
      ),
    );
  }
}