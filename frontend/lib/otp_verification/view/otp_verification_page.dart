import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/otp_verification/cubit/otp_verification_cubit.dart';
import 'package:frontend/theme/app_colors.dart';

class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({
    super.key,
    required this.emailOrPhone,
    this.onVerified,
    this.onBack,
  });

  /// The email or phone number the code was sent to (shown in the
  /// subtitle, e.g. "Code sent to name@email.com").
  final String emailOrPhone;

  /// Called once the code has been successfully verified.
  /// Use this to navigate to the ResetPasswordPage.
  final VoidCallback? onVerified;

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpVerificationCubit(),
      child: _OtpVerificationView(
        emailOrPhone: emailOrPhone,
        onVerified: onVerified,
        onBack: onBack,
      ),
    );
  }
}

class _OtpVerificationView extends StatefulWidget {
  const _OtpVerificationView({
    required this.emailOrPhone,
    this.onVerified,
    this.onBack,
  });

  final String emailOrPhone;
  final VoidCallback? onVerified;
  final VoidCallback? onBack;

  @override
  State<_OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<_OtpVerificationView> {
  static const int _codeLength = OtpVerificationState.codeLength;

  late final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(BuildContext context, int index, String value) {
    if (value.length > 1) {
      // Handles pasting a full code into one box.
      _distributePastedCode(value);
      return;
    }

    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    _emitCode(context);
  }

  void _distributePastedCode(String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    for (var i = 0; i < _codeLength; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    _focusNodes[_codeLength - 1].requestFocus();
    _emitCode(context);
  }

  void _emitCode(BuildContext context) {
    final code = _controllers.map((c) => c.text).join();
    context.read<OtpVerificationCubit>().codeChanged(code);
  }

  void _clearBoxes() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocConsumer<OtpVerificationCubit, OtpVerificationState>(
          listener: (context, state) {
            if (state.isSuccess) {
              widget.onVerified?.call();
            }
            if (state.code.isEmpty) {
              // Cleared externally (e.g. after a resend) — clear boxes too.
              _clearBoxes();
            }
          },
          builder: (context, state) {
            return Column(
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
                          context.l10n.otpTitle,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.otpSubtitle(widget.emailOrPhone),
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildCodeBoxes(context, state),
                        if (state.isFailure) ...[
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.incorrectCodeError,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        _buildVerifyButton(context, state),
                        const SizedBox(height: 20),
                        _buildResendRow(context, state),
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

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
            onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
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

  Widget _buildCodeBoxes(BuildContext context, OtpVerificationState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = state.isFailure
        ? colorScheme.error
        : colorScheme.outlineVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_codeLength, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: _codeLength, // allows pasting the full code here
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.darkTeal,
                  width: 1.8,
                ),
              ),
            ),
            onChanged: (value) => _onDigitChanged(context, index, value),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton(BuildContext context, OtpVerificationState state) {
    final enabled = state.isComplete && !state.isVerifying;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled
            ? () => context.read<OtpVerificationCubit>().verify()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTeal,
          disabledBackgroundColor: AppColors.darkTeal.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: state.isVerifying
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
                    context.l10n.verifyLabel,
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

  Widget _buildResendRow(BuildContext context, OtpVerificationState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.didNotReceiveCodeLabel,
          style: const TextStyle(fontSize: 14, color: AppColors.darkTeal),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: state.canResend
              ? () => context.read<OtpVerificationCubit>().resendCode()
              : null,
          child: Text(
            state.canResend
                ? context.l10n.resendCodeLabel
                : context.l10n.resendTimerLabel(state.resendSecondsRemaining),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: state.canResend
                  ? AppColors.darkTeal
                  : AppColors.darkTeal.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }
}
