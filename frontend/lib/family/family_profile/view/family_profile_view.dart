import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/core/widgets/auth_date_field.dart';
import 'package:frontend/core/widgets/auth_text_field.dart';
import 'package:frontend/core/widgets/primary_pill_button.dart';
import 'package:frontend/core/widgets/profile_picture_picker.dart';
import 'package:frontend/theme/app_colors.dart';

import '../cubit/family_profile_cubit.dart';

class FamilyProfileView extends StatelessWidget {
  const FamilyProfileView({super.key, this.onLogOut, this.showTopBar = true});

  final VoidCallback? onLogOut;
  final bool showTopBar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      body: SafeArea(
        child: BlocBuilder<FamilyProfileCubit, FamilyProfileState>(
          builder: (context, state) {
            final cubit = context.read<FamilyProfileCubit>();

            return Column(
              children: [
                if (showTopBar) _ProfileTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PersonalInfoCard(state: state, cubit: cubit),
                        const SizedBox(height: 20),
                        _ActionsSection(
                          state: state,
                          cubit: cubit,
                          onLogOut: onLogOut,
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 16),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTeal,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoCard extends StatelessWidget {
  const _PersonalInfoCard({required this.state, required this.cubit});

  final FamilyProfileState state;
  final FamilyProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: state.isEditing
              ? ProfilePicturePicker(
                  key: ValueKey('avatar-${state.editSessionId}'),
                  imageBytes: state.profileImageBytes,
                  onImagePicked: cubit.profileImagePicked,
                )
              : CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.paleMint,
                  backgroundImage: state.profileImageBytes != null
                      ? MemoryImage(state.profileImageBytes!)
                      : null,
                  child: state.profileImageBytes == null
                      ? const Icon(Icons.person, size: 44, color: AppColors.darkTeal)
                      : null,
                ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            state.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Center(
          child: Text(
            state.email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!state.isEditing) ...[
                _ReadOnlyInfoRows(state: state),
              ] else ...[
                _EditableInfoFields(state: state, cubit: cubit),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryPillButton(
                        label: 'Cancel',
                        isOutlined: true,
                        icon: null,
                        onPressed: cubit.cancelEditing,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryPillButton(
                        label: 'Save',
                        icon: Icons.check,
                        isLoading: state.isSaving,
                        onPressed: cubit.saveChanges,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyInfoRows extends StatelessWidget {
  const _ReadOnlyInfoRows({required this.state});

  final FamilyProfileState state;

  @override
  Widget build(BuildContext context) {
    final dobLabel = state.dateOfBirth != null
        ? DateFormat('d MMM yyyy').format(state.dateOfBirth!)
        : '—';

    return Column(
      children: [
        _InfoRow(
          icon: Icons.person_outline,
          label: 'Full Name',
          value: state.name,
        ),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: 'Phone Number',
          value: state.phone,
        ),
        _InfoRow(
          icon: Icons.location_on_outlined,
          label: 'Address',
          value: state.address,
        ),
        _InfoRow(
          icon: state.gender == Gender.male ? Icons.man_outlined : Icons.woman_outlined,
          label: 'Gender',
          value: state.gender?.label(context) ?? '—',
        ),
        _InfoRow(
          icon: Icons.cake_outlined,
          label: 'Date of Birth',
          value: dobLabel,
          isLast: true,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.darkTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableInfoFields extends StatelessWidget {
  const _EditableInfoFields({required this.state, required this.cubit});

  final FamilyProfileState state;
  final FamilyProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final sessionKeyPrefix = 'field-${state.editSessionId}';

    return Column(
      children: [
        AuthTextField(
          key: ValueKey('$sessionKeyPrefix-name'),
          label: 'Full Name',
          hintText: 'e.g. John Doe',
          prefixIcon: Icons.person_outline,
          initialValue: state.name,
          onChanged: cubit.nameChanged,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          key: ValueKey('$sessionKeyPrefix-phone'),
          label: 'Phone Number',
          hintText: 'e.g. +8801XXXXXXXXX',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          initialValue: state.phone,
          onChanged: cubit.phoneChanged,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          key: ValueKey('$sessionKeyPrefix-address'),
          label: 'Address',
          hintText: 'e.g. Dhaka',
          prefixIcon: Icons.location_on_outlined,
          initialValue: state.address,
          onChanged: cubit.addressChanged,
        ),
        const SizedBox(height: 16),
        _ReadOnlyEditField(
          label: 'Gender',
          icon: state.gender == Gender.male ? Icons.man_outlined : Icons.woman_outlined,
          value: state.gender?.label(context) ?? '—',
        ),
        const SizedBox(height: 16),
        AuthDateField(
          key: ValueKey('$sessionKeyPrefix-dob'),
          label: 'Date of Birth',
          value: state.dateOfBirth,
          onChanged: cubit.dateOfBirthChanged,
        ),
      ],
    );
  }
}

class _ReadOnlyEditField extends StatelessWidget {
  const _ReadOnlyEditField({
    required this.label,
    required this.icon,
    required this.value,
  });

  final String label;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75)),
              const SizedBox(width: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionsSection extends StatelessWidget {
  const _ActionsSection({
    required this.state,
    required this.cubit,
    this.onLogOut,
  });

  final FamilyProfileState state;
  final FamilyProfileCubit cubit;
  final VoidCallback? onLogOut;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (!state.isEditing)
          _ActionRow(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            color: colorScheme.onSurface,
            backgroundColor: AppColors.darkTeal.withValues(alpha: 0.1),
            onTap: cubit.startEditing,
          ),
        const SizedBox(height: 10),
        _ActionRow(
          icon: Icons.logout,
          label: 'Log Out',
          color: colorScheme.error,
          backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.2),
          onTap: () {
            cubit.logOut();
            if (onLogOut != null) {
              onLogOut!.call();
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 16, color: color),
                ),
              ),
              Icon(Icons.chevron_right, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
