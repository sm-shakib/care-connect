import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../../booking_detail/view/booking_detail_page.dart';
import '../cubit/caregiver_detail_cubit.dart';
import '../cubit/caregiver_detail_state.dart';
import 'widgets/caregiver_actions_bar.dart';
import 'widgets/caregiver_documents_section.dart';
import 'widgets/caregiver_earnings_section.dart';
import 'widgets/caregiver_profile_header.dart';
import 'widgets/caregiver_quick_facts_grid.dart';
import 'widgets/caregiver_recent_bookings_section.dart';
import 'widgets/caregiver_specializations_section.dart';
import 'widgets/caregiver_verification_status_card.dart';

enum _MenuAction { toggleStatus, remove }

/// Presentational scaffold for the Caregiver Profile detail screen.
/// Pushed from `user_management` when an admin taps an already-active
/// caregiver (distinct from `caregiver_review`, which is for pending
/// applications).
class CaregiverDetailView extends StatelessWidget {
  const CaregiverDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CaregiverDetailCubit, CaregiverDetailState>(
      listenWhen: (previous, current) =>
      previous.action != current.action &&
          current.action != CaregiverDetailAction.none,
      listener: (context, state) {
        final cubit = context.read<CaregiverDetailCubit>();
        switch (state.action) {
          case CaregiverDetailAction.statusChanged:
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.isSuspended
                        ? 'Account suspended.'
                        : 'Account reactivated.',
                  ),
                ),
              );
            cubit.consumeAction();
          case CaregiverDetailAction.payoutRetried:
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Payout retry initiated.')),
              );
            cubit.consumeAction();
          case CaregiverDetailAction.removed:
            Navigator.of(context).pop();
          case CaregiverDetailAction.none:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: _buildAppBar(context),
        body: BlocBuilder<CaregiverDetailCubit, CaregiverDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.loadStatus == CaregiverDetailLoadStatus.failure) {
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

            final profile = state.profile;
            if (profile == null) return const SizedBox.shrink();

            final cubit = context.read<CaregiverDetailCubit>();

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
                      200,
                    ),
                    children: [
                      CaregiverProfileHeader(profile: profile),
                      const SizedBox(height: 24),
                      CaregiverQuickFactsGrid(profile: profile),
                      const SizedBox(height: 20),
                      CaregiverSpecializationsSection(
                        specializations: profile.specializations,
                      ),
                      const SizedBox(height: 20),
                      CaregiverVerificationStatusCard(
                        isVerified: profile.isVerified,
                        checklist: profile.verificationChecklist,
                      ),
                      const SizedBox(height: 20),
                      CaregiverEarningsSection(
                        profile: profile,
                        onViewStatements: () {
                          // TODO(careconnect): no statements/export page
                          // exists yet.
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text('Statements coming soon.'),
                              ),
                            );
                        },
                        onRetryPayout: (payout) => cubit.retryPayout(payout.id),
                      ),
                      const SizedBox(height: 20),
                      CaregiverDocumentsSection(documents: profile.documents),
                      const SizedBox(height: 20),
                      CaregiverRecentBookingsSection(
                        bookings: profile.recentBookings,
                        onViewAll: () {
                          // TODO(careconnect): navigate to this
                          // caregiver's full booking history.
                        },
                        onBookingTap: (booking) {
                          Navigator.of(context).push(
                            BookingDetailPage.route(bookingId: booking.id),
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
        bottomSheet: BlocBuilder<CaregiverDetailCubit, CaregiverDetailState>(
          buildWhen: (previous, current) =>
          previous.profile?.status != current.profile?.status,
          builder: (context, state) {
            if (state.profile == null) return const SizedBox.shrink();
            final cubit = context.read<CaregiverDetailCubit>();
            return CaregiverActionsBar(
              isSuspended: state.isSuspended,
              onToggleStatus: cubit.toggleAccountStatus,
              onRemove: () => _confirmRemove(context, cubit),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmRemove(
      BuildContext context,
      CaregiverDetailCubit cubit,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove this user?'),
        content: const Text(
          "This permanently deletes the caregiver's account and cannot "
              'be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorLight),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cubit.removeUser();
    }
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
        'Caregiver Profile',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryLight,
        ),
      ),
      actions: [
        Builder(
          builder: (context) {
            return BlocBuilder<CaregiverDetailCubit, CaregiverDetailState>(
              buildWhen: (previous, current) =>
              previous.profile?.status != current.profile?.status,
              builder: (context, state) {
                final cubit = context.read<CaregiverDetailCubit>();
                return PopupMenuButton<_MenuAction>(
                  icon: Icon(Icons.more_vert, color: AppColors.primaryLight),
                  onSelected: (action) {
                    switch (action) {
                      case _MenuAction.toggleStatus:
                        cubit.toggleAccountStatus();
                      case _MenuAction.remove:
                        _confirmRemove(context, cubit);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _MenuAction.toggleStatus,
                      child: Row(
                        children: [
                          Icon(
                            state.isSuspended ? Icons.check_circle : Icons.block,
                            color: AppColors.onSurfaceVariantLight,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            state.isSuspended
                                ? 'Reactivate Account'
                                : 'Suspend Account',
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _MenuAction.remove,
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppColors.errorLight),
                          const SizedBox(width: 12),
                          Text(
                            'Remove User',
                            style: TextStyle(color: AppColors.errorLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 360 ? 16 : 20;
  }
}