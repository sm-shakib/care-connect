import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/login_cubit.dart';

class LoginPage extends StatelessWidget {
  final VoidCallback? onSignUp;
  final VoidCallback? onForgotPassword;
  final ValueChanged<LoginState>? onLoginSuccess;

  const LoginPage({
    super.key,
    this.onSignUp,
    this.onForgotPassword,
    this.onLoginSuccess,
  });

  static const Color kBackgroundColor = Color(0xFFEFF2FC);
  static const Color kPrimaryBlue = Color(0xFF1E3FCB);
  static const Color kTitleColor = Color(0xFF1B1D28);
  static const Color kSubtitleColor = Color(0xFF6B6F8A);
  static const Color kFieldBorderColor = Color(0xFFD9DEEF);

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
  final VoidCallback? onSignUp;
  final VoidCallback? onForgotPassword;
  final ValueChanged<LoginState>? onLoginSuccess;

  const _LoginView({
    this.onSignUp,
    this.onForgotPassword,
    this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginPage.kBackgroundColor,
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
                        color: LoginPage.kTitleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Log in to continue your care journey.',
                      style: TextStyle(
                        fontSize: 14,
                        color: LoginPage.kSubtitleColor,
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
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const _FieldLabel('Password'),
                                GestureDetector(
                                  onTap: onForgotPassword,
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: LoginPage.kPrimaryBlue,
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
                                  color: LoginPage.kSubtitleColor,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: LoginPage.kPrimaryBlue),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          //const SizedBox(width: 4),
          //const Icon(Icons.favorite, color: LoginPage.kPrimaryBlue, size: 22),
          //const SizedBox(width: 8),
          const Text(
            'CareConnect',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: LoginPage.kPrimaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginState state) {
    final bool enabled = state.isValid && !state.isSubmitting;
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
          backgroundColor: LoginPage.kPrimaryBlue,
          disabledBackgroundColor: LoginPage.kPrimaryBlue.withOpacity(0.4),
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
            style: TextStyle(fontSize: 14, color: LoginPage.kSubtitleColor),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onSignUp,
            child: const Text(
              'Sign up',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: LoginPage.kPrimaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: LoginPage.kTitleColor,
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const _LoginTextField({
    required this.hintText,
    required this.prefixIcon,
    required this.onChanged,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15, color: LoginPage.kTitleColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFB4B8CC)),
        prefixIcon: Icon(prefixIcon, color: LoginPage.kSubtitleColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LoginPage.kFieldBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LoginPage.kFieldBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LoginPage.kPrimaryBlue, width: 1.6),
        ),
      ),
    );
  }
}