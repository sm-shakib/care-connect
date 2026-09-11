import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver/caregiver_dashboard/view/caregiver_dashboard_page.dart';
import 'package:frontend/core/repositories/auth_repository.dart';

import 'package:frontend/login/login.dart';
import 'package:frontend/role_selection/role_selection.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/welcome_screen/welcome_screen.dart';
import '../cubit/caregiver_pending_cubit.dart';
import 'document_reupload_page.dart';

class CaregiverPendingView extends StatelessWidget {
  const CaregiverPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<CaregiverPendingCubit, CaregiverPendingState>(
      listener: (context, state) {
        if (state.status == CaregiverPendingStatus.verified) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const CaregiverDashboardPage(),
            ),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'CareConnect',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkTeal,
              ),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Column(
                children: [
                  Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      size: 58,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Verification Pending',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkTeal,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (state.adminNotes != null &&
                      state.adminNotes!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.feedback_outlined,
                                  size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Admin Feedback',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.adminNotes!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final success = await Navigator.push<bool>(
                            context,
                            DocumentReuploadPage.route(),
                          );
                          if (success == true) {
                            context
                                .read<CaregiverPendingCubit>()
                                .refreshStatus();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.upload_file),
                        label: const Text(
                          'Fix & Re-upload Documents',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Thank you for registering as a caregiver.\n\n'
                      'Your account is currently under review by our administrators.\n\n'
                      'You will be able to access all caregiver features once your verification has been completed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.orange,
                            size: 28,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Estimated Verification Time',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.darkTeal,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '24 - 48 Hours',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: state.status == CaregiverPendingStatus.loading
                          ? null
                          : () => context
                              .read<CaregiverPendingCubit>()
                              .refreshStatus(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: state.status == CaregiverPendingStatus.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Refresh Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextButton.icon(
                    onPressed: () async {
                      // Clear persistent storage and reset chat
                      await AuthRepository().logout();

                      if (!context.mounted) return;

                      // Navigate back to the root (Welcome/Login)
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginPage(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.home_outlined,
                      color: AppColors.darkTeal,
                    ),
                    label: const Text(
                      'Go to Welcome Page',
                      style: TextStyle(
                        color: AppColors.darkTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
