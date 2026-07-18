import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/caregiver_signup/cubit/caregiver_signup_cubit.dart';
import 'package:frontend/core/widgets/auth_dropdown_field.dart';
import 'package:frontend/core/widgets/auth_text_field.dart';
import 'package:frontend/core/widgets/care_connect_app_bar.dart';
import 'package:frontend/core/widgets/document_upload_tile.dart';
import 'package:frontend/core/widgets/primary_pill_button.dart';
import 'package:frontend/core/widgets/profile_picture_picker.dart';
import 'package:frontend/core/widgets/step_progress_indicator.dart';
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

  static const List<String> _stepLabels = [
    'Basic Info',
    'Professional Info',
    'Documents',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                    steps: _stepLabels,
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
                          'Something went wrong. Please try again.',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      PrimaryPillButton(
                        label: state.isLastStep
                            ? 'Submit for Verification'
                            : 'Continue',
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
                            const Text(
                              'Already have an account?',
                              style: TextStyle(
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
                              child: const Text(
                                'Login',
                                style: TextStyle(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create Your Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start your journey as a verified caregiver on CareConnect.',
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
          label: 'Full Name',
          hintText: 'e.g. Nusrat Jahan',
          prefixIcon: Icons.person_outline,
          errorText: state.nameError,
          onChanged: cubit.nameChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: 'Phone Number',
          hintText: 'e.g. +8801XXXXXXXXX',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          errorText: state.phoneError,
          onChanged: cubit.phoneChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: 'Email',
          hintText: 'e.g. name@email.com',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          errorText: state.emailError,
          onChanged: cubit.emailChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: 'Address',
          hintText: 'e.g. House 12, Road 5, Dhaka',
          prefixIcon: Icons.location_on_outlined,
          errorText: state.addressError,
          onChanged: cubit.addressChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: 'Password',
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
          label: 'Confirm Password',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Professional Info',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell families what you specialize in and how you work.',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        AuthTextField(
          label: 'Specializations',
          hintText: 'e.g. Elderly mobility support, dementia care, '
              'post-surgery recovery...',
          prefixIcon: Icons.medical_services_outlined,
          maxLines: 4,
          errorText: state.specializationsError,
          onChanged: cubit.specializationsChanged,
        ),
        const SizedBox(height: 18),
        AuthDropdownField<AvailabilityType>(
          label: 'Availability',
          value: state.availabilityType,
          items: AvailabilityType.values,
          itemLabel: (type) => type.label,
          errorText: state.availabilityTypeError,
          onChanged: cubit.availabilityTypeChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: 'Daily Rate (৳)',
          hintText: 'e.g. 1500',
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
    final showError = state.submitAttempted && !state.isStep3Valid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Documents',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload these so our team can verify your profile before it '
              'goes live. Accepted formats: PDF, JPG, PNG.',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        for (final type in CaregiverDocumentType.values) ...[
          DocumentUploadTile(
            documentTypeLabel: type.label,
            fileName: state.uploadedDocuments[type]?.name,
            onFilePicked: (file) => cubit.documentPicked(type, file),
          ),
          const SizedBox(height: 14),
        ],
        if (showError) ...[
          const SizedBox(height: 4),
          Text(
            'Please upload all required documents.',
            style: TextStyle(fontSize: 13, color: colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}