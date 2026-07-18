import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';

class CaregiverPendingView extends StatelessWidget {
  const CaregiverPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          'Your account is still under review. Please check again later.',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.white),
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
                onPressed: () {},
                icon: const Icon(
                  Icons.support_agent,
                  color: AppColors.darkTeal,
                ),
                label: const Text(
                  'Contact Support',
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
  }
}