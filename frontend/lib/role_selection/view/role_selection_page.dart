import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/role_selection/cubit/role_selection_cubit.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  static const Color kBackgroundColor = Color(0xFFEFF2FC);
  static const Color kCardColor = Color(0xFFE4E9FB);
  static const Color kCardSelectedColor = Color(0xFFD7DFFB);
  static const Color kPrimaryBlue = Color(0xFF4C6EF5);
  static const Color kTitleColor = Color(0xFF1B1D28);
  static const Color kSubtitleColor = Color(0xFF6B6F8A);

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
    return Scaffold(
      backgroundColor: RoleSelectionPage.kBackgroundColor,
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
                        color: RoleSelectionPage.kTitleColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select your profile to personalize your\n'
                          'experience and access the right tools.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: RoleSelectionPage.kPrimaryBlue),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Text(
            'CareConnect',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            width: 48,
          ),
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
                final role =
                context.read<RoleSelectionCubit>().confirmSelection();
                // TODO: navigate based on the selected role.
                debugPrint('Selected role: $role');
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: RoleSelectionPage.kPrimaryBlue,
                disabledBackgroundColor: RoleSelectionPage.kPrimaryBlue
                    .withValues(alpha: 0.35),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? RoleSelectionPage.kCardSelectedColor
              : RoleSelectionPage.kCardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? RoleSelectionPage.kPrimaryBlue
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(
                icon,
                size: 32,
                color: RoleSelectionPage.kPrimaryBlue,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: RoleSelectionPage.kTitleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: RoleSelectionPage.kSubtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}