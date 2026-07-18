import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../cubit/caregiver_review_cubit.dart';
import '../cubit/caregiver_review_state.dart';
import 'widgets/bio_section.dart';
import 'widgets/contact_info_card.dart';
import 'widgets/document_preview_page.dart';
import 'widgets/personal_details_grid.dart';
import 'widgets/review_bottom_action_bar.dart';
import 'widgets/review_profile_header.dart';
import 'widgets/specializations_section.dart';
import 'widgets/uploaded_documents_section.dart';
import 'widgets/verification_checklist_card.dart';

/// Presentational scaffold for the Caregiver Application Review screen.
/// Content is centered with a max width on larger screens, and the
/// bottom action bar is pinned via `bottomSheet` (not scrolled with the
/// rest of the content) to match the sticky footer in the design.
class CaregiverReviewView extends StatelessWidget {
  const CaregiverReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CaregiverReviewCubit, CaregiverReviewState>(
      listenWhen: (previous, current) =>
      previous.decision != current.decision &&
          current.decision != CaregiverReviewDecision.none,
      listener: (context, state) {
        final message = switch (state.decision) {
          CaregiverReviewDecision.approved => 'Application approved.',
          CaregiverReviewDecision.docsRequested =>
          'Document request sent to caregiver.',
          CaregiverReviewDecision.rejected => 'Application rejected.',
          CaregiverReviewDecision.none => '',
        };
        if (message.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: _buildAppBar(context),
        body: BlocBuilder<CaregiverReviewCubit, CaregiverReviewState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == CaregiverReviewStatus.failure) {
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

            final application = state.application;
            if (application == null) return const SizedBox.shrink();

            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      _horizontalPadding(context),
                      16,
                      _horizontalPadding(context),
                      // Extra bottom room so content clears the pinned
                      // bottom action bar.
                      280,
                    ),
                    children: [
                      ReviewProfileHeader(application: application),
                      const SizedBox(height: 20),
                      ContactInfoCard(application: application),
                      const SizedBox(height: 12),
                      PersonalDetailsGrid(application: application),
                      const SizedBox(height: 20),
                      SpecializationsSection(
                        specializations: application.specializations,
                      ),
                      const SizedBox(height: 20),
                      BioSection(bio: application.bio),
                      const SizedBox(height: 12),
                      VerificationChecklistCard(
                        checklist: application.checklist,
                        completedCount: application.completedChecklistCount,
                      ),
                      const SizedBox(height: 20),
                      UploadedDocumentsSection(
                        documents: application.documents,
                        onViewAll: () {},
                        onPreview: (document) {
                          Navigator.of(context).push(
                            DocumentPreviewPage.route(document),
                          );
                        },
                        onExpand: (document) {
                          Navigator.of(context).push(
                            DocumentPreviewPage.route(document),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomSheet: BlocBuilder<CaregiverReviewCubit, CaregiverReviewState>(
          buildWhen: (previous, current) =>
          previous.adminNotes != current.adminNotes ||
              previous.submitStatus != current.submitStatus,
          builder: (context, state) {
            final cubit = context.read<CaregiverReviewCubit>();
            return ReviewBottomActionBar(
              notes: state.adminNotes,
              isSubmitting: state.isSubmitting,
              onNotesChanged: cubit.notesChanged,
              onApprove: cubit.approve,
              onRequestDocs: cubit.requestDocs,
              onReject: cubit.reject,
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
        'Application Review',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryLight,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: AppColors.onSurfaceVariantLight),
          onPressed: () {},
        ),
      ],
    );
  }

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 360 ? 16 : 20;
  }
}