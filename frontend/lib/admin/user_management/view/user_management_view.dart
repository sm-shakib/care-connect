import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../../elderly_detail/view/elderly_detail_page.dart';
import '../cubit/user_management_cubit.dart';
import '../cubit/user_management_state.dart';
import '../cubit/user_model.dart';
import 'widgets/user_filter_chips.dart';
import 'widgets/user_list_card.dart';
import 'widgets/user_search_bar.dart';

/// Tab body for the User Management screen, rendered inside
/// `AdminShellView`'s `IndexedStack`. No back button, no bottom nav bar
/// of its own — the shell provides one shared nav bar for all tabs.
/// Reads state from [UserManagementCubit] via [BlocBuilder] and stays
/// responsive by centering content with a max width on larger screens.
class UserManagementView extends StatelessWidget {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO(careconnect): navigate to the add-user flow.
        },
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.person_add, size: 28),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _horizontalPadding(context),
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UserSearchBar(
                    onChanged:
                    context.read<UserManagementCubit>().searchChanged,
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<UserManagementCubit, UserManagementState>(
                    buildWhen: (previous, current) =>
                    previous.filter != current.filter,
                    builder: (context, state) {
                      return UserFilterChips(
                        selected: state.filter,
                        onSelected:
                        context.read<UserManagementCubit>().filterChanged,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BlocBuilder<UserManagementCubit,
                        UserManagementState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state.status == UserManagementStatus.failure) {
                          return Center(
                            child: Text(
                              state.errorMessage ?? 'Something went wrong.',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariantLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        final users = state.filteredUsers;

                        if (users.isEmpty) {
                          return Center(
                            child: Text(
                              'No users match your search.',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariantLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh:
                          context.read<UserManagementCubit>().loadUsers,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            // Extra bottom room so the last card clears
                            // the floating action button.
                            padding: const EdgeInsets.only(bottom: 88),
                            itemCount: users.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return UserListCard(
                                user: user,
                                onTap: () => _openUserDetail(context, user),
                                onViewDetails: () =>
                                    _openUserDetail(context, user),
                                onToggleStatus: () {
                                  // TODO(careconnect): call the
                                  // suspend/reactivate endpoint.
                                },
                                onRemove: () {
                                  // TODO(careconnect): call the
                                  // remove-user endpoint (with a
                                  // confirmation dialog).
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      shape: Border(
        bottom: BorderSide(color: AppColors.outlineVariantLight),
      ),
      title: Text(
        'User Management',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryLight,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, color: AppColors.primaryLight),
          onPressed: () {},
        ),
      ],
    );
  }

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 360 ? 16 : 20;
  }

  /// Routes to the right detail page based on the tapped user's role.
  /// Only [UserRole.elderly] has a built detail page so far — Family
  /// Member and Caregiver detail pages are still TODO, so those show a
  /// "coming soon" snackbar instead of navigating nowhere.
  void _openUserDetail(BuildContext context, UserAccount user) {
    switch (user.role) {
      case UserRole.elderly:
        Navigator.of(context).push(
          ElderlyDetailPage.route(userId: user.id),
        );
      case UserRole.family:
      case UserRole.caregiver:
      case UserRole.admin:
      // TODO(careconnect): build FamilyMemberDetailPage and
      // CaregiverDetailPage, then route to them here the same way as
      // ElderlyDetailPage above.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('${user.role.label} profile page coming soon.'),
            ),
          );
    }
  }
}