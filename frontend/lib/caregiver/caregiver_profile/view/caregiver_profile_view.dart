import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:frontend/caregiver_signup/caregiver_signup.dart';
import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/core/widgets/auth_date_field.dart';
import 'package:frontend/core/widgets/auth_dropdown_field.dart';
import 'package:frontend/core/widgets/auth_text_field.dart';
import 'package:frontend/core/widgets/primary_pill_button.dart';
import 'package:frontend/core/widgets/profile_picture_picker.dart';
import 'package:frontend/core/widgets/success_dialog.dart';
import 'package:frontend/caregiver/caregiver_earnings/caregiver_earnings.dart';
import 'package:frontend/caregiver/caregiver_profile/view/caregiver_reports_page.dart';
import 'package:frontend/login/view/login_page.dart';
import 'package:frontend/app/cubit/locale_cubit.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/theme/app_colors.dart';

import '../cubit/caregiver_profile_cubit.dart';
import '../widgets/profile_top_bar.dart';
import '../widgets/verified_document_tile.dart';

class CaregiverProfileView extends StatelessWidget {
  const CaregiverProfileView({super.key, this.onLogOut, this.showTopBar = true});

  final VoidCallback? onLogOut;
  final bool showTopBar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      //backgroundColor: colorScheme.surface,
      backgroundColor: const Color(0xFFFBFEFC),
      body: SafeArea(
        child: BlocBuilder<CaregiverProfileCubit, CaregiverProfileState>(
          builder: (context, state) {
            if (state.status == CaregiverProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == CaregiverProfileStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Failed to load profile: ${state.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<CaregiverProfileCubit>().loadProfile(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final cubit = context.read<CaregiverProfileCubit>();

            return Column(
              children: [
                if (showTopBar) const ProfileTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PersonalInfoCard(state: state, cubit: cubit),
                        const SizedBox(height: 16),
                        _EarningsCard(state: state),
                        const SizedBox(height: 16),
                        _VerifiedDocumentsSection(state: state),
                        const SizedBox(height: 20),
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
                              fontSize: 12,
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

class _PersonalInfoCard extends StatelessWidget {
  const _PersonalInfoCard({required this.state, required this.cubit});

  final CaregiverProfileState state;
  final CaregiverProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // return Container(
    //   padding: const EdgeInsets.all(18),
    //   decoration: BoxDecoration(
    //     color: colorScheme.surfaceContainerLowest,
    //     borderRadius: BorderRadius.circular(18),
    //     border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
    //   ),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       ...
    //   ),
    // );
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
                  // radius: 38,
                  radius: 48,
                  backgroundColor: AppColors.paleMint,
                  backgroundImage: state.profileImageBytes != null
                      ? MemoryImage(state.profileImageBytes!)
                      : (state.profileImageUrl.isNotEmpty
                          ? NetworkImage(state.profileImageUrl)
                          : null) as ImageProvider?,
                  child: (state.profileImageBytes == null &&
                          state.profileImageUrl.isEmpty)
                      ? const Icon(Icons.person,
                          size: 44, color: AppColors.darkTeal)
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
                // _StatsRow(state: state),
                // const SizedBox(height: 16),
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
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryPillButton(
                        label: context.l10n.saveLabel,
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state});

  final CaregiverProfileState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _StatBox(
            colorScheme: colorScheme,
            label: context.l10n.experienceLabel,
            value: context.l10n.yearsLabel(
              int.tryParse(state.experienceYears) ?? 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            colorScheme: colorScheme,
            label: context.l10n.locationLabel,
            value: state.address,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.colorScheme, required this.label, required this.value});

  final ColorScheme colorScheme;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyInfoRows extends StatelessWidget {
  const _ReadOnlyInfoRows({required this.state});

  final CaregiverProfileState state;

  @override
  Widget build(BuildContext context) {
    final dobLabel = state.dateOfBirth != null
        ? DateFormat('d MMM yyyy').format(state.dateOfBirth!)
        : '—';

    return Column(
      children: [
        _InfoRow(
          icon: Icons.work_history_outlined,
          label: context.l10n.experienceLabel,
          value: context.l10n.yearsLabel(
            int.tryParse(state.experienceYears) ?? 0,
          ),
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
        // _InfoRow(icon: Icons.wc_outlined, label: 'Gender', value: state.gender?.label ?? '—'),
        _InfoRow(
          icon: state.gender == Gender.male
              ? Icons.man_outlined
              : Icons.woman_outlined,
          label: context.l10n.genderLabel,
          value: state.gender?.label(context) ?? '—',
        ),
        _InfoRow(icon: Icons.cake_outlined, label: context.l10n.dateOfBirthLabel, value: dobLabel),
        _InfoRow(
          icon: Icons.medical_services_outlined,
          label: context.l10n.specializationsLabel,
          value: state.specializations,
        ),
        _InfoRow(
          icon: Icons.event_available_outlined,
          label: context.l10n.availabilityLabel,
          value: state.availabilityType?.label(context) ?? '—',
        ),
        _InfoRow(
          icon: Icons.payments_outlined,
          label: context.l10n.dailyRateLabel,
          value: context.l10n.hourlyRateLabel(
            int.tryParse(state.hourlyRate) ?? 0,
          ),
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
            //child: Icon(icon, size: 18, color: colorScheme.primary),
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

  final CaregiverProfileState state;
  final CaregiverProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final sessionKeyPrefix = 'field-${state.editSessionId}';

    return Column(
      children: [
        AuthTextField(
          key: ValueKey('$sessionKeyPrefix-experience'),
          label: context.l10n.experienceYearsLabel,
          hintText: context.l10n.experienceYearsHint,
          prefixIcon: Icons.work_history_outlined,
          keyboardType: TextInputType.number,
          initialValue: state.experienceYears,
          onChanged: cubit.experienceYearsChanged,
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
        ),
        const SizedBox(height: 16),
        AuthTextField(
          key: ValueKey('$sessionKeyPrefix-address'),
          label: context.l10n.addressLabel,
          hintText: context.l10n.addressHint,
          prefixIcon: Icons.location_on_outlined,
          initialValue: state.address,
          onChanged: cubit.addressChanged,
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
        ),
        const SizedBox(height: 16),
        AuthTextField(
          key: ValueKey('$sessionKeyPrefix-specializations'),
          label: context.l10n.specializationsLabel,
          hintText: context.l10n.specializationsHint,
          prefixIcon: Icons.medical_services_outlined,
          maxLines: 3,
          initialValue: state.specializations,
          onChanged: cubit.specializationsChanged,
        ),
        const SizedBox(height: 16),
        AuthDropdownField<AvailabilityType>(
          key: ValueKey('$sessionKeyPrefix-availability'),
          label: context.l10n.availabilityLabel,
          value: state.availabilityType,
          items: AvailabilityType.values,
          itemLabel: (type) => type.label(context),
          onChanged: cubit.availabilityTypeChanged,
        ),
        const SizedBox(height: 16),
        _ReadOnlyEditField(
          label: context.l10n.dailyRateLabel,
          icon: Icons.payments_outlined,
          value: context.l10n.hourlyRateLabel(
            int.tryParse(state.hourlyRate) ?? 0,
          ),
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
            // color: Colors.white,
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              // Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
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

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.state});

  final CaregiverProfileState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime.now());
    final payoutDateLabel = state.lastPayoutDate != null
        ? DateFormat('MMMM d, yyyy').format(state.lastPayoutDate!)
        : '—';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.earningsSummaryTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              // Text(
              //   monthLabel,
              //   style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              // ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\৳${state.totalEarningsThisMonth.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              // Text(
              //   'Total this month',
              //   style: TextStyle(fontSize: 12, color: colorScheme.tertiary),
              // ),
            ],
          ),
          // const SizedBox(height: 18),
          // _EarningsSparkline(values: state.earningsSparkline, color: colorScheme.primary),
          // const SizedBox(height: 18),
          // Container(
          //   padding: const EdgeInsets.all(14),
          //   decoration: BoxDecoration(
          //     color: colorScheme.surfaceContainer,
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          // children: [
          //   Text(
          //     'Last Payout',
          //     style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          //   ),
          //   // Text(
          //   //   '\$${state.lastPayoutAmount.toStringAsFixed(2)}',
          //   //   style: TextStyle(
          //   //     fontSize: 16,
          //   //     fontWeight: FontWeight.bold,
          //   //     color: colorScheme.onSurface,
          //   //   ),
          //   ),
          // ],
          // ),
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.end,
          //         children: [
          //           Text(
          //             'Date',
          //             style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          //           ),
          //           Text(
          //             payoutDateLabel,
          //             style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider(
                      create: (_) => CaregiverEarningsCubit(),
                      child: const CaregiverEarningsView(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                //backgroundColor: colorScheme.primary,
                backgroundColor: AppColors.darkTeal,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.l10n.viewEarningsHistoryLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsSparkline extends StatelessWidget {
  const _EarningsSparkline({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            Expanded(
              child: FractionallySizedBox(
                heightFactor: maxValue == 0 ? 0.1 : (values[i] / maxValue).clamp(0.1, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: i == values.length - 1 ? color : color.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              ),
            ),
            if (i != values.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _VerifiedDocumentsSection extends StatelessWidget {
  const _VerifiedDocumentsSection({required this.state});

  final CaregiverProfileState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final documentTypes = state.documents.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.verifiedDocumentsTitle,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < documentTypes.length; i++) ...[
                VerifiedDocumentTile(
                  type: documentTypes[i],
                  fileName: state.documents[documentTypes[i]]!,
                  onView: () {
                    // TODO: open a preview of this document.
                  },
                ),
                if (i != documentTypes.length - 1)
                  Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ],
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

  final CaregiverProfileState state;
  final CaregiverProfileCubit cubit;
  final VoidCallback? onLogOut;

  void _showLanguagePicker(BuildContext context) {
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (!state.isEditing) ...[
          _ActionRow(
            icon: Icons.edit_outlined,
            label: context.l10n.editProfileLabel,
            color: colorScheme.onSurface,
            //backgroundColor: colorScheme.surfaceContainerLow,
            backgroundColor: AppColors.darkTeal.withValues(alpha: 0.1),
            onTap: cubit.startEditing,
          ),
          const SizedBox(height: 10),
          _ActionRow(
            icon: Icons.feedback_outlined,
            label: 'Service Feedback',
            color: colorScheme.onSurface,
            backgroundColor: AppColors.darkTeal.withValues(alpha: 0.1),
            onTap: () {
              Navigator.push(context, CaregiverReportsPage.route());
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
        // _ActionRow(
        //   icon: Icons.help_outline,
        //   label: 'Help & Support',
        //   color: colorScheme.onSurface,
        //   //backgroundColor: colorScheme.surfaceContainerLow,
        //   backgroundColor: AppColors.darkTeal.withValues(alpha: 0.1),
        //   onTap: () {
        //     // TODO: navigate to help & support.
        //   },
        // ),
        const SizedBox(height: 10),
        _ActionRow(
          icon: Icons.logout,
          label: context.l10n.logoutLabel,
          color: colorScheme.error,
          backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.2),
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final cubit = context.read<CaregiverProfileCubit>();
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
                cubit.logOut();

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