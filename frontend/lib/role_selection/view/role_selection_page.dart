import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/caregiver_signup/view/caregiver_signup_page.dart';
import 'package:frontend/elderly_signup/view/elderly_signup_page.dart';
import 'package:frontend/family_signup/view/family_signup_page.dart';
import 'package:frontend/family/view/family_dashboard_page.dart';
import 'package:frontend/role_selection/cubit/role_selection_cubit.dart';
import 'package:frontend/theme/app_colors.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoleSelectionCubit(),
      child: const _RoleSelectionView(),
    );
  }
}

class _RoleSelectionView extends StatelessWidget {
  const _RoleSelectionView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Who are you?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTeal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Select your profile to personalize your\n'
                          'experience and access the right tools.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<RoleSelectionCubit, RoleSelectionState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            _RoleCard(
                              role: UserRole.elderlyPerson,
                              title: 'Elderly Person',
                              subtitle: 'Manage health and daily walks',
                              icon: Icons.elderly,
                              isSelected:
                              state.selectedRole == UserRole.elderlyPerson,
                              onTap: () => context
                                  .read<RoleSelectionCubit>()
                                  .selectRole(UserRole.elderlyPerson),
                            ),
                            const SizedBox(height: 18),
                            _RoleCard(
                              role: UserRole.caregiver,
                              title: 'Caregiver',
                              subtitle: 'Monitor patients and provide care',
                              icon: Icons.medical_services_outlined,
                              isSelected:
                              state.selectedRole == UserRole.caregiver,
                              onTap: () => context
                                  .read<RoleSelectionCubit>()
                                  .selectRole(UserRole.caregiver),
                            ),
                            const SizedBox(height: 18),
                            _RoleCard(
                              role: UserRole.familyMember,
                              title: 'Family Member',
                              subtitle: 'Stay connected and updated',
                              icon: Icons.family_restroom,
                              isSelected:
                              state.selectedRole == UserRole.familyMember,
                              onTap: () => context
                                  .read<RoleSelectionCubit>()
                                  .selectRole(UserRole.familyMember),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildContinueButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Text(
            'CareConnect',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return BlocBuilder<RoleSelectionCubit, RoleSelectionState>(
      builder: (context, state) {
        final enabled = state.isRoleSelected;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: enabled
                  ? () {
                final role = context
                    .read<RoleSelectionCubit>()
                    .confirmSelection();

                Widget? page;

                switch (role) {
                  case UserRole.familyMember:
                    page = const FamilyDashboardPage();
                    break;

                  case UserRole.elderlyPerson:
                    page = const ElderlySignupPage();
                    break;

                  case UserRole.caregiver:
                    page = const CaregiverSignupPage();
                    break;

                  case null:
                    break;
                }

                if (page != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => page!,
                    ),
                  );
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkTeal,
                disabledBackgroundColor:
                AppColors.darkTeal.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(140),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final UserRole role;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 22,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkTeal
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.darkTeal
                : colorScheme.outlineVariant,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor:
              isSelected ? Colors.white : colorScheme.surface,
              child: Icon(
                icon,
                size: 32,
                color: AppColors.darkTeal,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color:
                isSelected ? Colors.white : AppColors.darkTeal,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? Colors.white70
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}