import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/forgot_password/view/forgot_password_page.dart';
import 'package:frontend/login/cubit/login_cubit.dart';
import 'package:frontend/reset_password/view/reset_password_page.dart';
import 'package:frontend/role_selection/role_selection.dart';
import 'package:frontend/theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    this.onSignUp,
    this.onForgotPassword,
    this.onLoginSuccess,
  });

  final VoidCallback? onSignUp;
  final VoidCallback? onForgotPassword;
  final ValueChanged<LoginState>? onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: _LoginView(
        onSignUp: onSignUp,
        onForgotPassword: onForgotPassword,
        onLoginSuccess: onLoginSuccess,
      ),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView({
    this.onSignUp,
    this.onForgotPassword,
    this.onLoginSuccess,
  });

  final VoidCallback? onSignUp;
  final VoidCallback? onForgotPassword;
  final ValueChanged<LoginState>? onLoginSuccess;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Log in to continue your care journey.',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    BlocBuilder<LoginCubit, LoginState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Email or Phone Number'),
                            const SizedBox(height: 8),
                            _LoginTextField(
                              hintText: 'e.g. name@email.com',
                              prefixIcon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) => context
                                  .read<LoginCubit>()
                                  .emailOrPhoneChanged(value),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const _FieldLabel('Password'),
                                GestureDetector(
                                  onTap:
                                      onForgotPassword ??
                                      () async {
                                        await Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (context) => ForgotPasswordPage(
                                              onBackToLogin: () =>
                                                  Navigator.of(context).pop(),
                                              onCodeSent: (emailOrPhone) async {
                                                await Navigator.pushReplacement<
                                                  void,
                                                  void
                                                >(
                                                  context,
                                                  MaterialPageRoute<void>(
                                                    builder: (context) =>
                                                        ResetPasswordPage(
                                                          onResetSuccess: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).popUntil(
                                                                (route) => route
                                                                    .isFirst,
                                                              ),
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkTeal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _LoginTextField(
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscureText: state.isPasswordObscured,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  state.isPasswordObscured
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () => context
                                    .read<LoginCubit>()
                                    .togglePasswordVisibility(),
                              ),
                              onChanged: (value) => context
                                  .read<LoginCubit>()
                                  .passwordChanged(value),
                            ),
                            const SizedBox(height: 32),
                            _buildLoginButton(context, state),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildSignUpRow(context),
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
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          //const SizedBox(width: 4),
          //const Icon(Icons.favorite, color: LoginPage.kPrimaryBlue, size: 22),
          //const SizedBox(width: 8),
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

  Widget _buildLoginButton(BuildContext context, LoginState state) {
    final enabled = state.isValid && !state.isSubmitting;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled
            ? () async {
                await context.read<LoginCubit>().submit();
                if (context.mounted) {
                  onLoginSuccess?.call(context.read<LoginCubit>().state);
                }
              }
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
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildSignUpRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account?",
            style: TextStyle(fontSize: 14, color: AppColors.darkTeal),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap:
                onSignUp ??
                () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const RoleSelectionPage(),
                    ),
                  );
                },
            child: const Text(
              'Sign up',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkTeal,
              ),
            ),
          ),
        ],
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

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
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
