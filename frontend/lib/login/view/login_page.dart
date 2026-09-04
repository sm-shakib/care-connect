import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/admin/admin_shell/admin_shell.dart';
import 'package:frontend/caregiver/caregiver_dashboard/caregiver_dashboard.dart';
import 'package:frontend/caregiver/caregiver_pending/caregiver_pending.dart';
import 'package:frontend/elderly/dashboard/elderly_dashboard.dart';
import 'package:frontend/family/view/family_dashboard_page.dart';
import 'package:frontend/forgot_password/view/forgot_password_page.dart';
import 'package:frontend/login/cubit/login_cubit.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/otp_verification/view/otp_verification_page.dart';
import 'package:frontend/reset_password/view/reset_password_page.dart';
import 'package:frontend/role_selection/role_selection.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/core/widgets/success_dialog.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onSignUp,
    this.onForgotPassword,
    this.onLoginSuccess,
    this.showLogoutSuccess = false,
  });

  final VoidCallback? onSignUp;
  final VoidCallback? onForgotPassword;
  final ValueChanged<LoginState>? onLoginSuccess;
  final bool showLogoutSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    if (widget.showLogoutSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLogoutSuccessDialog();
      });
    }
  }

  void _showLogoutSuccessDialog() {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return SuccessDialog(
            title: 'Logged Out',
            message: 'You have been logged out successfully.',
            onDone: () => Navigator.pop(dialogContext),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: _LoginView(
        onSignUp: widget.onSignUp,
        onForgotPassword: widget.onForgotPassword,
        onLoginSuccess: widget.onLoginSuccess,
      ),
    );
  }
}

enum _LoginRole {
  elder,
  caregiver,
  family,
  admin,
}

class _LoginView extends StatefulWidget {
  const _LoginView({
    this.onSignUp,
    this.onForgotPassword,
    this.onLoginSuccess,
  });

  final VoidCallback? onSignUp;
  final VoidCallback? onForgotPassword;
  final ValueChanged<LoginState>? onLoginSuccess;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  _LoginRole? _selectedRole;

  void _navigateBasedOnRole(BuildContext context, String? role, String? status) {
    if (role == 'elder') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => const ElderlyDashboardPage()),
        (route) => false,
      );
    } else if (role == 'family') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => const FamilyDashboardPage()),
        (route) => false,
      );
    } else if (role == 'caregiver') {
      if (status == 'verified') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(
              builder: (_) => const CaregiverDashboardPage()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(
              builder: (_) => const CaregiverPendingPage()),
          (route) => false,
        );
      }
    } else if (role == 'admin') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => const AdminShellPage()),
        (route) => false,
      );
    }
  }

  void _showLoginSuccessDialog(BuildContext pageContext, LoginState state) {
    unawaited(
      showDialog<void>(
        context: pageContext,
        barrierDismissible: false,
        builder: (dialogContext) {
          return _LoginSuccessDialog(
            onDone: () {
              Navigator.pop(dialogContext);
              _navigateBasedOnRole(pageContext, state.role, state.accountStatus);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.isSuccess) {
              if (state.role == 'family') {
                _showLoginSuccessDialog(context, state);
              } else {
                _navigateBasedOnRole(context, state.role, state.accountStatus);
              }
            } else if (state.isFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Login failed'),
                  backgroundColor: colorScheme.error,
                ),
              );
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
                    Text(
                      context.l10n.loginWelcomeTitle,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.loginSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 28),
                    BlocBuilder<LoginCubit, LoginState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel(context.l10n.emailOrPhoneLabel),
                            const SizedBox(height: 8),
                            _LoginTextField(
                              hintText: context.l10n.emailHint,
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
                                _FieldLabel(context.l10n.passwordLabel),
                                GestureDetector(
                                  onTap: widget.onForgotPassword ??
                                          () async {
                                        await Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (context) => ForgotPasswordPage(
                                              onBackToLogin: () => Navigator.of(context).pop(),
                                              onCodeSent: (emailOrPhone) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute<void>(
                                                    builder: (context) => OtpVerificationPage(
                                                      emailOrPhone: emailOrPhone,
                                                      onVerified: () {
                                                        Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute<void>(
                                                            builder: (context) => ResetPasswordPage(
                                                              onResetSuccess: () => Navigator.of(context)
                                                                  .popUntil((route) => route.isFirst),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                  child: Text(
                                    context.l10n.forgotPasswordLabel,
                                    style: const TextStyle(
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
                              onChanged: (value) =>
                                  context.read<LoginCubit>().passwordChanged(value),
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
            context.l10n.careConnectTitle,
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
            ? () => context.read<LoginCubit>().submit()
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
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.login,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
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
          Text(
            context.l10n.dontHaveAccountLabel,
            style: const TextStyle(fontSize: 14, color: AppColors.darkTeal),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: widget.onSignUp ??
                    () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const RoleSelectionPage(),
                    ),
                  );
                },
            child: Text(
              context.l10n.signupLabel,
              style: const TextStyle(
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

class _LoginSuccessDialog extends StatelessWidget {
  const _LoginSuccessDialog({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return SuccessDialog(
      title: 'Welcome Back!',
      message: 'Logged in successfully. Redirecting to your dashboard...',
      onDone: onDone,
    );
  }
}

class _RoleSelectorRow extends StatelessWidget {
  const _RoleSelectorRow({
    required this.selectedRole,
    required this.onRoleSelected,
  });

  final _LoginRole? selectedRole;
  final ValueChanged<_LoginRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: _RoleBox(
              label: 'Elder',
              icon: Icons.elderly,
              isSelected: selectedRole == _LoginRole.elder,
              onTap: () => onRoleSelected(_LoginRole.elder),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: _RoleBox(
              label: 'Caregiver',
              icon: Icons.medical_services_outlined,
              isSelected: selectedRole == _LoginRole.caregiver,
              onTap: () => onRoleSelected(_LoginRole.caregiver),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: _RoleBox(
              label: 'Family',
              icon: Icons.family_restroom,
              isSelected: selectedRole == _LoginRole.family,
              onTap: () => onRoleSelected(_LoginRole.family),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: _RoleBox(
              label: 'Admin',
              icon: Icons.admin_panel_settings_outlined,
              isSelected: selectedRole == _LoginRole.admin,
              onTap: () => onRoleSelected(_LoginRole.admin),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBox extends StatelessWidget {
  const _RoleBox({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkTeal
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.darkTeal,
            width: isSelected ? 1.8 : 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : AppColors.darkTeal,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.darkTeal,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
