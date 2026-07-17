import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../cubit/user_management_cubit.dart';
import '../cubit/user_management_state.dart';
import 'widgets/user_bottom_nav_bar.dart';
import 'widgets/user_filter_chips.dart';
import 'widgets/user_list_card.dart';
import 'widgets/user_search_bar.dart';

/// Presentational scaffold for the User Management screen. Reads state
/// from [UserManagementCubit] via [BlocBuilder] and stays responsive by
/// centering content with a max width on larger screens.
class UserManagementView extends StatelessWidget {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(context),
      bottomNavigationBar: const UserManagementBottomNavBar(),
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
                                onTap: () {
                                  // TODO(careconnect): navigate to the
                                  // user detail page.
                                },
                                onViewDetails: () {
                                  // TODO(careconnect): navigate to the
                                  // user detail page.
                                },
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
      shape: Border(
        bottom: BorderSide(color: AppColors.outlineVariantLight),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.onSurfaceLight),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        'User Management',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceLight,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: AppColors.onSurfaceLight),
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