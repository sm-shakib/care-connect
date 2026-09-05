import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../../caregiver_detail/view/caregiver_detail_page.dart';
import '../../elderly_detail/view/elderly_detail_page.dart';
import '../../family_member_detail/view/family_member_detail_page.dart';
import '../cubit/complaint_detail_cubit.dart';
import '../cubit/complaint_detail_model.dart';
import '../cubit/complaint_detail_state.dart';
import 'widgets/add_note_sheet.dart';
import 'widgets/complaint_actions_bar.dart';
import 'widgets/complaint_status_card.dart';
import 'widgets/description_section.dart';
import 'widgets/internal_notes_section.dart';
import 'widgets/people_involved_section.dart';

class _ResolutionFeedbackSection extends StatelessWidget {
  const _ResolutionFeedbackSection({required this.feedback});
  final String feedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paleMint.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.feedback_outlined, size: 20, color: AppColors.primaryLight),
              const SizedBox(width: 8),
              Text(
                'Official Resolution Feedback',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            feedback,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.onSurfaceLight,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaregiverExplanationSection extends StatelessWidget {
  const _CaregiverExplanationSection({required this.explanation});
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.record_voice_over_outlined, size: 20, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Caregiver\'s Explanation',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.onSurfaceLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Presentational scaffold for the Complaint Details screen. The bottom
/// action bar is pinned via `bottomSheet` (like `caregiver_review`) so
/// it floats above scrolling content instead of being part of it.
class ComplaintDetailView extends StatelessWidget {
  const ComplaintDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ComplaintDetailCubit, ComplaintDetailState>(
      listenWhen: (previous, current) =>
      previous.action != current.action &&
          current.action != ComplaintDetailAction.none,
      listener: (context, state) {
        final message = switch (state.action) {
          ComplaintDetailAction.resolved => 'Complaint marked as resolved.',
          ComplaintDetailAction.noteAdded => 'Internal note added.',
          ComplaintDetailAction.none => '',
        };
        if (message.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
        context.read<ComplaintDetailCubit>().consumeAction();
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: _buildAppBar(context),
        body: BlocBuilder<ComplaintDetailCubit, ComplaintDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.loadStatus == ComplaintDetailLoadStatus.failure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage ?? 'Something went wrong.',
                    style: TextStyle(color: AppColors.onSurfaceVariantLight),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final complaint = state.complaint;
            if (complaint == null) return const SizedBox.shrink();

            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      _horizontalPadding(context),
                      12,
                      _horizontalPadding(context),
                      // Extra bottom room so content clears the pinned
                      // bottom action bar.
                      140,
                    ),
                    children: [
                      ComplaintStatusCard(complaint: complaint),
                      const SizedBox(height: 12),
                      PeopleInvolvedSection(
                        reporter: complaint.reporter,
                        against: complaint.against,
                        onReporterTap: () => _openPersonDetail(context, complaint.reporter),
                        onAgainstTap: () => _openPersonDetail(context, complaint.against),
                      ),
                      const SizedBox(height: 12),
                      DescriptionSection(description: complaint.description),
                      const SizedBox(height: 12),
                      if (complaint.caregiverExplanation != null &&
                          complaint.caregiverExplanation!.isNotEmpty) ...[
                        _CaregiverExplanationSection(
                          explanation: complaint.caregiverExplanation!,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (complaint.resolutionFeedback != null &&
                          complaint.resolutionFeedback!.isNotEmpty) ...[
                        _ResolutionFeedbackSection(
                          feedback: complaint.resolutionFeedback!,
                        ),
                        const SizedBox(height: 12),
                      ],
                      InternalNotesSection(
                        notes: complaint.internalNotes,
                        onAddNote: () async {
                          final note = await AddNoteSheet.show(context);
                          if (note != null) {
                            await context
                                .read<ComplaintDetailCubit>()
                                .addInternalNote(note);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomSheet: BlocBuilder<ComplaintDetailCubit, ComplaintDetailState>(
          buildWhen: (previous, current) =>
          previous.complaint?.status != current.complaint?.status,
          builder: (context, state) {
            final cubit = context.read<ComplaintDetailCubit>();
            return ComplaintActionsBar(
              isResolved: state.isResolved,
              onResolve: () async {
                final feedback = await _showResolutionFeedbackDialog(context);
                if (feedback != null) {
                  await cubit.addResolutionFeedback(feedback);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<String?> _showResolutionFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Resolve Complaint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the official feedback that will be visible to the reporter.',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariantLight),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'e.g. Investigation completed. Corrective measures taken...',
                filled: true,
                fillColor: AppColors.surfaceContainerLowLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm Resolve'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(
        bottom: BorderSide(color: AppColors.outlineVariantLight),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primaryLight),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        'Complaint Details',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryLight,
        ),
      ),
      /*actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: AppColors.onSurfaceVariantLight),
          onPressed: () {},
        ),
      ],*/
    );
  }

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 360 ? 16 : 20;
  }

  void _openPersonDetail(BuildContext context, Person person) {
    switch (person.role.toLowerCase()) {
      case 'elder':
      case 'elderly':
        Navigator.of(context).push(
          ElderlyDetailPage.route(userId: person.id),
        );
      case 'family':
      case 'family member':
        Navigator.of(context).push(
          FamilyMemberDetailPage.route(userId: person.id),
        );
      case 'caregiver':
        Navigator.of(context).push(
          CaregiverDetailPage.route(userId: person.id),
        );
      default:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('${person.role} profile page coming soon.'),
            ),
          );
    }
  }
}