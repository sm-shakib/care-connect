import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/caregiver_signup/cubit/caregiver_signup_cubit.dart';
import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/core/widgets/auth_date_field.dart';
import 'package:frontend/core/widgets/auth_dropdown_field.dart';
import 'package:frontend/core/widgets/auth_text_field.dart';
import 'package:frontend/core/widgets/care_connect_app_bar.dart';
import 'package:frontend/core/widgets/document_upload_tile.dart';
import 'package:frontend/core/widgets/primary_pill_button.dart';
import 'package:frontend/core/widgets/profile_picture_picker.dart';
import 'package:frontend/core/widgets/step_progress_indicator.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/login/login.dart';
import 'package:frontend/theme/app_colors.dart';

class CaregiverSignupPage extends StatelessWidget {
  const CaregiverSignupPage({super.key, this.onSignupSuccess, this.onLogin});

  final VoidCallback? onSignupSuccess;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverSignupCubit(),
      child: _CaregiverSignupView(
        onSignupSuccess: onSignupSuccess,
        onLogin: onLogin,
      ),
    );
  }
}

class _CaregiverSignupView extends StatelessWidget {
  const _CaregiverSignupView({this.onSignupSuccess, this.onLogin});

  final VoidCallback? onSignupSuccess;
  final VoidCallback? onLogin;

  static List<String> _stepLabels(AppLocalizations l10n) => [
    l10n.basicInfoStepLabel,
    l10n.professionalInfoStepLabel,
    l10n.documentsStepLabel,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocConsumer<CaregiverSignupCubit, CaregiverSignupState>(
          listener: (context, state) {
            if (state.isSuccess) onSignupSuccess?.call();
          },
          builder: (context, state) {
            final cubit = context.read<CaregiverSignupCubit>();

            return Column(
              children: [
                CareConnectAppBar(
                  onBack: state.currentStep == 0
                      ? () => Navigator.of(context).maybePop()
                      : cubit.previousStep,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: StepProgressIndicator(
                    steps: _stepLabels(l10n),
                    currentStep: state.currentStep,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: switch (state.currentStep) {
                      0 => _BasicInfoStep(state: state, cubit: cubit),
                      1 => _ProfessionalInfoStep(state: state, cubit: cubit),
                      _ => _DocumentsStep(state: state, cubit: cubit),
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Column(
                    children: [
                      if (state.status == CaregiverSignupStatus.failure) ...[
                        Text(
                          l10n.genericFailureMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      PrimaryPillButton(
                        label: state.isLastStep
                            ? l10n.submitForVerificationLabel
                            : l10n.continueLabel,
                        icon: state.isLastStep
                            ? Icons.check
                            : Icons.arrow_forward,
                        isLoading: state.isSubmitting,
                        onPressed: cubit.nextStep,
                      ),
                      if (state.currentStep == 0) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.alreadyHaveAccount,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.darkTeal,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: onLogin ??
                                      () async {
                                    await Navigator.push<void>(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  },
                              child: Text(
                                l10n.login,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkTeal,
                                ),
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
          },
        ),
      ),
    );
  }
}

class _BasicInfoStep extends StatelessWidget {
  const _BasicInfoStep({required this.state, required this.cubit});

  final CaregiverSignupState state;
  final CaregiverSignupCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.createAccountTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.caregiverSignupSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: ProfilePicturePicker(
            imageBytes: state.profileImageBytes,
            errorText: state.imageError,
            onImagePicked: cubit.profileImagePicked,
          ),
        ),
        const SizedBox(height: 24),
        AuthTextField(
          label: l10n.fullNameLabel,
          hintText: l10n.caregiverNameHint,
          prefixIcon: Icons.person_outline,
          errorText: state.nameError,
          onChanged: cubit.nameChanged,
        ),
        const SizedBox(height: 18),
        AuthDropdownField<Gender>(
          label: l10n.genderLabel,
          value: state.gender,
          items: Gender.values,
          itemLabel: (gender) => gender.label(context),
          errorText: state.genderError,
          onChanged: cubit.genderChanged,
        ),
        const SizedBox(height: 18),
        AuthDateField(
          label: l10n.dateOfBirthLabel,
          value: state.dateOfBirth,
          errorText: state.dateOfBirthError,
          onChanged: cubit.dateOfBirthChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: l10n.phoneNumberLabel,
          hintText: l10n.phoneNumberHint,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          errorText: state.phoneError,
          onChanged: cubit.phoneChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: l10n.emailLabel,
          hintText: l10n.emailHint,
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          errorText: state.emailError,
          onChanged: cubit.emailChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: l10n.addressLabel,
          hintText: l10n.addressHint,
          prefixIcon: Icons.location_on_outlined,
          errorText: state.addressError,
          onChanged: cubit.addressChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: l10n.passwordLabel,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: state.isPasswordObscured,
          errorText: state.passwordError,
          suffixIcon: IconButton(
            icon: Icon(
              state.isPasswordObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: cubit.togglePasswordVisibility,
          ),
          onChanged: cubit.passwordChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: l10n.confirmPasswordLabel,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: state.isConfirmPasswordObscured,
          errorText: state.confirmPasswordError,
          suffixIcon: IconButton(
            icon: Icon(
              state.isConfirmPasswordObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: cubit.toggleConfirmPasswordVisibility,
          ),
          onChanged: cubit.confirmPasswordChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ProfessionalInfoStep extends StatelessWidget {
  const _ProfessionalInfoStep({required this.state, required this.cubit});

  final CaregiverSignupState state;
  final CaregiverSignupCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.professionalInfoStepLabel,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.professionalInfoSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        AuthTextField(
          label: l10n.specializationsLabel,
          hintText: l10n.specializationsHint,
          prefixIcon: Icons.medical_services_outlined,
          maxLines: 4,
          errorText: state.specializationsError,
          onChanged: cubit.specializationsChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: l10n.experienceYearsLabel,
          hintText: l10n.experienceYearsHint,
          prefixIcon: Icons.work_history_outlined,
          keyboardType: TextInputType.number,
          errorText: state.experienceYearsError,
          onChanged: cubit.experienceYearsChanged,
        ),
        const SizedBox(height: 18),
        AuthDropdownField<AvailabilityType>(
          label: l10n.availabilityLabel,
          value: state.availabilityType,
          items: AvailabilityType.values,
          itemLabel: (type) => type.label(context),
          errorText: state.availabilityTypeError,
          onChanged: cubit.availabilityTypeChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: l10n.dailyRateLabel,
          hintText: l10n.dailyRateHint,
          prefixIcon: Icons.payments_outlined,
          keyboardType: TextInputType.number,
          errorText: state.dailyRateError,
          onChanged: cubit.dailyRateChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _DocumentsStep extends StatelessWidget {
  const _DocumentsStep({required this.state, required this.cubit});

  final CaregiverSignupState state;
  final CaregiverSignupCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final showError = state.submitAttempted && !state.isStep3Valid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.verificationDocumentsTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.verificationDocumentsSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        for (final type in CaregiverDocumentType.values) ...[
          DocumentUploadTile(
            documentTypeLabel: type.label(context),
            fileName: state.uploadedDocuments[type]?.name,
            onFilePicked: (file) => cubit.documentPicked(type, file),
          ),
          const SizedBox(height: 14),
        ],
        if (showError) ...[
          const SizedBox(height: 4),
          Text(
            l10n.uploadAllDocumentsError,
            style: TextStyle(fontSize: 13, color: colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}