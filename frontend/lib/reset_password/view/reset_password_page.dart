import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/reset_password/cubit/reset_password_cubit.dart';
import 'package:frontend/theme/app_colors.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({
    super.key,
    this.onResetSuccess,
  });

  /// Called once the password has been successfully reset.
  /// Use this to navigate back to the LoginPage.
  final VoidCallback? onResetSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResetPasswordCubit(),
      child: _ResetPasswordView(onResetSuccess: onResetSuccess),
    );
  }
}

class _ResetPasswordView extends StatelessWidget {
  const _ResetPasswordView({this.onResetSuccess});

  final VoidCallback? onResetSuccess;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocListener<ResetPasswordCubit, ResetPasswordState>(
          listener: (context, state) {
            if (state.isSuccess) {
              onResetSuccess?.call();
            }
          },
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkTeal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a new password for your account. Make sure '
                        "it's at least 8 characters long.",
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('New Password'),
                              const SizedBox(height: 8),
                              _RecoveryTextField(
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                obscureText: state.isNewPasswordObscured,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    state.isNewPasswordObscured
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () => context
                                      .read<ResetPasswordCubit>()
                                      .toggleNewPasswordVisibility(),
                                ),
                                onChanged: (value) => context
                                    .read<ResetPasswordCubit>()
                                    .newPasswordChanged(value),
                              ),
                              const SizedBox(height: 20),
                              const _FieldLabel('Confirm Password'),
                              const SizedBox(height: 8),
                              _RecoveryTextField(
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                obscureText: state.isConfirmPasswordObscured,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    state.isConfirmPasswordObscured
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () => context
                                      .read<ResetPasswordCubit>()
                                      .toggleConfirmPasswordVisibility(),
                                ),
                                onChanged: (value) => context
                                    .read<ResetPasswordCubit>()
                                    .confirmPasswordChanged(value),
                              ),
                              if (state.confirmPassword.isNotEmpty &&
                                  !state.passwordsMatch) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Passwords do not match.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.error,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 32),
                              _buildSubmitButton(context, state),
                              if (state.status ==
                                  ResetPasswordStatus.failure) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Something went wrong. Please try again.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.error,
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Text(
            'CareConnect',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, ResetPasswordState state) {
    final enabled = state.isValid && !state.isSubmitting;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled
            ? () => context.read<ResetPasswordCubit>().submit()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTeal,
          disabledBackgroundColor: AppColors.darkTeal.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: state.isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.check, color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTeal,
      ),
    );
  }
}

class _RecoveryTextField extends StatelessWidget {
  const _RecoveryTextField({
    required this.hintText,
    required this.prefixIcon,
    required this.onChanged,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
  });

  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(prefixIcon, color: colorScheme.onSurfaceVariant),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkTeal, width: 1.6),
        ),
      ),
    );
  }
}
