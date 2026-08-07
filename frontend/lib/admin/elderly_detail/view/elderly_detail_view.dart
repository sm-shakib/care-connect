import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../../family_member_detail/view/family_member_detail_page.dart';
import '../cubit/elderly_detail_cubit.dart';
import '../cubit/elderly_detail_state.dart';
import 'widgets/elderly_actions_bar.dart';
import 'widgets/elderly_address_card.dart';
import 'widgets/elderly_health_condition_card.dart';
import 'widgets/elderly_profile_header.dart';
import 'widgets/elderly_quick_facts_grid.dart';
import 'widgets/linked_family_members_section.dart';
import 'widgets/recent_sos_events_section.dart';

enum _MenuAction { toggleStatus, remove }

/// Presentational scaffold for the Elderly Profile detail screen.
/// Pushed from `user_management` when an admin taps an elderly user.
class ElderlyDetailView extends StatelessWidget {
  const ElderlyDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ElderlyDetailCubit, ElderlyDetailState>(
      listenWhen: (previous, current) =>
      previous.action != current.action &&
          current.action != ElderlyDetailAction.none,
      listener: (context, state) {
        final cubit = context.read<ElderlyDetailCubit>();
        if (state.action == ElderlyDetailAction.statusChanged) {
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
        } else if (state.action == ElderlyDetailAction.removed) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: _buildAppBar(context),
        body: BlocBuilder<ElderlyDetailCubit, ElderlyDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.loadStatus == ElderlyDetailLoadStatus.failure) {
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
                      ElderlyProfileHeader(profile: profile),
                      const SizedBox(height: 24),
                      ElderlyQuickFactsGrid(profile: profile),
                      const SizedBox(height: 12),
                      ElderlyHealthConditionCard(
                        healthCondition: profile.healthCondition,
                      ),
                      const SizedBox(height: 20),
                      LinkedFamilyMembersSection(
                        members: profile.linkedFamilyMembers,
                        onEdit: () {
                          // TODO(careconnect): open a linked-family-member
                          // edit flow.
                        },
                        onMemberTap: (member) {
                          Navigator.of(context).push(
                            FamilyMemberDetailPage.route(
                              userId: member.id,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      RecentSosEventsSection(events: profile.recentSosEvents),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomSheet: BlocBuilder<ElderlyDetailCubit, ElderlyDetailState>(
          buildWhen: (previous, current) =>
          previous.profile?.status != current.profile?.status,
          builder: (context, state) {
            if (state.profile == null) return const SizedBox.shrink();
            final cubit = context.read<ElderlyDetailCubit>();
            return ElderlyActionsBar(
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
      ElderlyDetailCubit cubit,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove this user?'),
        content: const Text(
          "This permanently deletes the elderly user's account and "
              'cannot be undone.',
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
        'Elderly Profile',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryLight,
        ),
      ),
      actions: [
        Builder(
          builder: (context) {
            return BlocBuilder<ElderlyDetailCubit, ElderlyDetailState>(
              buildWhen: (previous, current) =>
              previous.profile?.status != current.profile?.status,
              builder: (context, state) {
                final cubit = context.read<ElderlyDetailCubit>();
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