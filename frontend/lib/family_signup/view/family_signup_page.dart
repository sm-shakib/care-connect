import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/core/widgets/auth_date_field.dart';
import 'package:frontend/core/widgets/auth_dropdown_field.dart';
import 'package:frontend/core/widgets/auth_text_field.dart';
import 'package:frontend/core/widgets/care_connect_app_bar.dart';
import 'package:frontend/core/widgets/primary_pill_button.dart';
import 'package:frontend/core/widgets/profile_picture_picker.dart';
import 'package:frontend/family_signup/cubit/family_signup_cubit.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/login/login.dart';
import 'package:frontend/theme/app_colors.dart';

class FamilySignupPage extends StatelessWidget {
  const FamilySignupPage({super.key, this.onSignupSuccess, this.onLogin});

  /// Called once the account has been created successfully.
  final VoidCallback? onSignupSuccess;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FamilySignupCubit(),
      child: _FamilySignupView(
        onSignupSuccess: onSignupSuccess,
        onLogin: onLogin,
      ),
    );
  }
}

class _FamilySignupView extends StatelessWidget {
  const _FamilySignupView({this.onSignupSuccess, this.onLogin});

  final VoidCallback? onSignupSuccess;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocConsumer<FamilySignupCubit, FamilySignupState>(
          listener: (context, state) {
            if (state.isSuccess) onSignupSuccess?.call();
          },
          builder: (context, state) {
            final cubit = context.read<FamilySignupCubit>();

            return Column(
              children: [
                const CareConnectAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
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
                          l10n.familySignupSubtitle,
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
                          hintText: l10n.familyNameHint,
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
                        const SizedBox(height: 28),
                        PrimaryPillButton(
                          label: l10n.createAccountButtonLabel,
                          icon: Icons.check,
                          isLoading: state.isSubmitting,
                          onPressed: cubit.submit,
                        ),
                        if (state.status == FamilySignupStatus.failure) ...[
                          const SizedBox(height: 12),
                          Text(
                            l10n.genericFailureMessage,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 24),
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