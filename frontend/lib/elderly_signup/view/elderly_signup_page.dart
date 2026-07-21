import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/core/widgets/auth_date_field.dart';
import 'package:frontend/core/widgets/auth_dropdown_field.dart';
import 'package:frontend/core/widgets/auth_text_field.dart';
import 'package:frontend/core/widgets/care_connect_app_bar.dart';
import 'package:frontend/core/widgets/primary_pill_button.dart';
import 'package:frontend/core/widgets/profile_picture_picker.dart';
import 'package:frontend/core/widgets/step_progress_indicator.dart';
import 'package:frontend/elderly_signup/cubit/elderly_signup_cubit.dart';
import 'package:frontend/login/login.dart';
import 'package:frontend/theme/app_colors.dart';

class ElderlySignupPage extends StatelessWidget {
  const ElderlySignupPage({super.key, this.onSignupSuccess, this.onLogin});

  final VoidCallback? onSignupSuccess;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ElderlySignupCubit(),
      child: _ElderlySignupView(
        onSignupSuccess: onSignupSuccess,
        onLogin: onLogin,
      ),
    );
  }
}

class _ElderlySignupView extends StatelessWidget {
  const _ElderlySignupView({this.onSignupSuccess, this.onLogin});

  final VoidCallback? onSignupSuccess;
  final VoidCallback? onLogin;

  static const List<String> _stepLabels = ['Basic Info', 'Health Info'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocConsumer<ElderlySignupCubit, ElderlySignupState>(
          listener: (context, state) {
            if (state.isSuccess) onSignupSuccess?.call();
          },
          builder: (context, state) {
            final cubit = context.read<ElderlySignupCubit>();

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
                    child: state.currentStep == 0
                        ? _BasicInfoStep(state: state, cubit: cubit)
                        : _HealthInfoStep(state: state, cubit: cubit),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Column(
                    children: [
                      if (state.status == ElderlySignupStatus.failure) ...[
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
                        label: state.isLastStep ? 'Create Account' : 'Continue',
                        icon: state.isLastStep ? Icons.check : Icons.arrow_forward,
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

  final ElderlySignupState state;
  final ElderlySignupCubit cubit;

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
          'Let your caregivers and family know a bit about you.',
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
          hintText: 'e.g. Abdul Karim',
          prefixIcon: Icons.person_outline,
          errorText: state.nameError,
          onChanged: cubit.nameChanged,
        ),
        const SizedBox(height: 18),
        AuthDropdownField<Gender>(
          label: 'Gender',
          value: state.gender,
          items: Gender.values,
          itemLabel: (gender) => gender.label,
          errorText: state.genderError,
          onChanged: cubit.genderChanged,
        ),
        const SizedBox(height: 18),
        AuthDateField(
          label: 'Date of Birth',
          value: state.dateOfBirth,
          errorText: state.dateOfBirthError,
          onChanged: cubit.dateOfBirthChanged,
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

class _HealthInfoStep extends StatelessWidget {
  const _HealthInfoStep({required this.state, required this.cubit});

  final ElderlySignupState state;
  final ElderlySignupCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Information',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us match you with caregivers suited to your needs. '
              'You can update this anytime.',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        AuthTextField(
          label: 'Health Condition',
          hintText:
          'e.g. Type 2 diabetes, mild arthritis, needs help with '
              'daily walks...',
          prefixIcon: Icons.favorite_border,
          maxLines: 5,
          errorText: state.healthConditionError,
          onChanged: cubit.healthConditionChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}