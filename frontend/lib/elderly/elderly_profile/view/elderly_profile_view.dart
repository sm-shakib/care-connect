import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/cubit/locale_cubit.dart';
import 'package:frontend/core/donation/view/donation_flow_page.dart';
import 'package:frontend/core/donation/view/donation_history_page.dart';
import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/core/widgets/auth_date_field.dart';
import 'package:frontend/core/widgets/auth_text_field.dart';
import 'package:frontend/core/widgets/primary_pill_button.dart';
import 'package:frontend/core/widgets/profile_picture_picker.dart';
import 'package:frontend/core/widgets/success_dialog.dart';
import 'package:frontend/elderly/elderly_profile/cubit/elderly_profile_cubit.dart';
import 'package:frontend/elderly/view/assistance_form_page.dart';
import 'package:frontend/shared/complaints/user_complaints_page.dart';
import 'package:frontend/login/view/login_page.dart';
import 'package:frontend/shared/chat/data/chat_session.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:intl/intl.dart';

class ElderlyProfileView extends StatelessWidget {
  const ElderlyProfileView({super.key, this.onLogOut, this.showTopBar = true});

  final VoidCallback? onLogOut;
  final bool showTopBar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      body: SafeArea(
        child: BlocBuilder<ElderlyProfileCubit, ElderlyProfileState>(
          builder: (context, state) {
            if (state.status == ElderlyProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == ElderlyProfileStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Failed to load profile: ${state.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ElderlyProfileCubit>().loadProfile(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final cubit = context.read<ElderlyProfileCubit>();

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
                        const SizedBox(height: 24),
                        
                        /// Donation System (Kept as requested)
                        _DonationSection(),
                        
                        const SizedBox(height: 24),
                        
                        /// Assistance Section (Kept for consistency)
                        _AssistanceSection(),
                        
                        const SizedBox(height: 24),
                        _ActionsSection(
                          state: state,
                          cubit: cubit,
                          onLogOut: onLogOut,
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            context.l10n.appVersionLabel('1.0.0'),
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Text(
            context.l10n.profileTitle,
            style: const TextStyle(
              fontSize: 24,
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

  final ElderlyProfileState state;
  final ElderlyProfileCubit cubit;

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
                  radius: 54,
                  backgroundColor: AppColors.paleMint,
                  backgroundImage: state.profileImageBytes != null
                      ? MemoryImage(state.profileImageBytes!)
                      : (state.profileImageUrl.isNotEmpty
                          ? NetworkImage(state.profileImageUrl)
                          : null) as ImageProvider?,
                  child: (state.profileImageBytes == null && state.profileImageUrl.isEmpty)
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.darkTeal,
                        )
                      : null,
                ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            state.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
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
              fontSize: 16,
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
                        label: context.l10n.cancelLabel,
                        isOutlined: true,
                        icon: null,
                        onPressed: cubit.cancelEditing,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryPillButton(
                        label: context.l10n.saveLabel,
                        icon: Icons.check,
                        isLoading: state.isSaving,
                        onPressed: cubit.saveChanges,
                        fontSize: 18,
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

  final ElderlyProfileState state;

  @override
  Widget build(BuildContext context) {
    final dobLabel = state.dateOfBirth != null
        ? DateFormat('d MMM yyyy').format(state.dateOfBirth!)
        : '—';

    return Column(
      children: [
        _InfoRow(
          icon: Icons.person_outline,
          label: context.l10n.fullNameLabel,
          value: state.name,
        ),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: context.l10n.phoneNumberLabel,
          value: state.phone,
        ),
        _InfoRow(
          icon: Icons.location_on_outlined,
          label: context.l10n.addressLabel,
          value: state.address,
        ),
        _InfoRow(
          icon: state.gender == Gender.male
              ? Icons.man_outlined
              : Icons.woman_outlined,
          label: context.l10n.genderLabel,
          value: state.gender?.label(context) ?? '—',
        ),
        _InfoRow(
          icon: Icons.cake_outlined,
          label: context.l10n.dateOfBirthLabel,
          value: dobLabel,
        ),
        _InfoRow(
          icon: Icons.favorite_border,
          label: context.l10n.healthConditionLabel,
          value: state.healthCondition.isNotEmpty ? state.healthCondition : '—',
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
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: AppColors.darkTeal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 18, color: colorScheme.onSurface),
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

  final ElderlyProfileState state;
  final ElderlyProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final sessionKeyPrefix = 'field-${state.editSessionId}';

    return Column(
      children: [
        AuthTextField(
          key: ValueKey('$sessionKeyPrefix-name'),
          label: context.l10n.fullNameLabel,
          hintText: context.l10n.fullNameLabel, // or a specific hint if needed
          prefixIcon: Icons.person_outline,
          initialValue: state.name,
          onChanged: cubit.nameChanged,
          labelFontSize: 16,
          fontSize: 18,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          key: ValueKey('$sessionKeyPrefix-phone'),
          label: context.l10n.phoneNumberLabel,
          hintText: context.l10n.phoneNumberHint,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          initialValue: state.phone,
          onChanged: cubit.phoneChanged,
          labelFontSize: 16,
          fontSize: 18,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          key: ValueKey('$sessionKeyPrefix-address'),
          label: context.l10n.addressLabel,
          hintText: context.l10n.addressHint,
          prefixIcon: Icons.location_on_outlined,
          initialValue: state.address,
          onChanged: cubit.addressChanged,
          labelFontSize: 16,
          fontSize: 18,
        ),
        const SizedBox(height: 16),
        _ReadOnlyEditField(
          label: context.l10n.genderLabel,
          icon: state.gender == Gender.male
              ? Icons.man_outlined
              : Icons.woman_outlined,
          value: state.gender?.label(context) ?? '—',
        ),
        const SizedBox(height: 16),
        AuthDateField(
          key: ValueKey('$sessionKeyPrefix-dob'),
          label: context.l10n.dateOfBirthLabel,
          value: state.dateOfBirth,
          onChanged: cubit.dateOfBirthChanged,
          labelFontSize: 16,
          fontSize: 18,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          key: ValueKey('$sessionKeyPrefix-health'),
          label: context.l10n.healthConditionLabel,
          hintText: context.l10n.healthConditionHint,
          prefixIcon: Icons.favorite_border,
          initialValue: state.healthCondition,
          onChanged: cubit.healthConditionChanged,
          labelFontSize: 16,
          fontSize: 18,
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
            fontSize: 16,
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
              Icon(icon, size: 22, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75)),
              const SizedBox(width: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
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

class _DonationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.paleMint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.volunteer_activism, size: 48, color: AppColors.primaryLight),
          const SizedBox(height: 12),
          Text(
            context.l10n.centralDonationFundTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                unawaited(
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const DonationFlowPage(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(context.l10n.donateNowLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.volunteer_activism_outlined, size: 48, color: Colors.blue),
          const SizedBox(height: 12),
          Text(
            context.l10n.assistanceTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.assistanceSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                unawaited(
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AssistanceFormPage(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(context.l10n.applyForAssistanceLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsSection extends StatelessWidget {
  const _ActionsSection({
    required this.state,
    required this.cubit,
    this.onLogOut,
  });

  final ElderlyProfileState state;
  final ElderlyProfileCubit cubit;
  final VoidCallback? onLogOut;

  void _showLanguagePicker(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: const Color(0xFFFBFEFC),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final currentLocale = Localizations.localeOf(context);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.selectLanguageTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkTeal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.language, color: AppColors.darkTeal),
                    title: Text(context.l10n.englishLanguageName),
                    trailing: currentLocale.languageCode == 'en'
                        ? const Icon(Icons.check_circle, color: AppColors.darkTeal)
                        : null,
                    onTap: () {
                      context.read<LocaleCubit>().setLocale(const Locale('en'));
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.language, color: AppColors.darkTeal),
                    title: Text(context.l10n.banglaLanguageName),
                    trailing: currentLocale.languageCode == 'bn'
                        ? const Icon(Icons.check_circle, color: AppColors.darkTeal)
                        : null,
                    onTap: () {
                      context.read<LocaleCubit>().setLocale(const Locale('bn'));
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (!state.isEditing) ...[
          _ActionRow(
            icon: Icons.history,
            label: context.l10n.donationHistoryLabel,
            color: colorScheme.onSurface,
            backgroundColor: AppColors.darkTeal.withValues(alpha: 0.1),
            onTap: () {
              unawaited(
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const DonationHistoryPage(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ActionRow(
            icon: Icons.edit_outlined,
            label: context.l10n.editProfileLabel,
            color: colorScheme.onSurface,
            backgroundColor: AppColors.darkTeal.withValues(alpha: 0.1),
            onTap: cubit.startEditing,
          ),
          const SizedBox(height: 10),
          _ActionRow(
            icon: Icons.report_problem_outlined,
            label: 'My Complaints',
            color: colorScheme.onSurface,
            backgroundColor: AppColors.darkTeal.withValues(alpha: 0.1),
            onTap: () {
              Navigator.push(context, UserComplaintsPage.route());
            },
          ),
          const SizedBox(height: 10),
          _ActionRow(
            icon: Icons.language_outlined,
            label: context.l10n.appLanguageValue(
              Localizations.localeOf(context).languageCode == 'en'
                  ? context.l10n.englishLanguageName
                  : context.l10n.banglaLanguageName,
            ),
            color: colorScheme.onSurface,
            backgroundColor: AppColors.darkTeal.withValues(alpha: 0.1),
            onTap: () => _showLanguagePicker(context),
          ),
        ],
        const SizedBox(height: 10),
        _ActionRow(
          icon: Icons.logout,
          label: context.l10n.logoutLabel,
          color: colorScheme.error,
          backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.2),
          onTap: () {
            _showLogoutDialog(context);
          },
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            context.l10n.logoutDialogTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: Text(
            context.l10n.logoutDialogContent,
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.cancelLabel,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close confirmation

                // Ends the chat session: drops the cached identity and
                // conversations, and closes the socket that is still
                // authenticated as this user.
                ChatSession.reset();

                // Navigate to login page and tell it to show the success dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => LoginPage(showLogoutSuccess: true),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warningRed,
              ),
              child: Text(
                context.l10n.logoutLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 18, color: color),
                ),
              ),
              Icon(Icons.chevron_right, color: color.withValues(alpha: 0.6), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
