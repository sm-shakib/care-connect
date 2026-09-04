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
              onResolve: cubit.resolve,
            );
          },
        ),
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