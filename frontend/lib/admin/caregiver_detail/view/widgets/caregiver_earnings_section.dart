import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:frontend/caregiver/caregiver_earnings/caregiver_earnings.dart';
import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_profile_model.dart';

/// "Earnings" section. Shows the total amount earned and a list of
/// recent earnings per booking, styled like the Caregiver Profile's
/// earnings card.
class CaregiverEarningsSection extends StatelessWidget {
  const CaregiverEarningsSection({
    required this.profile,
    this.onViewStatements,
    this.onRetryPayout,
    super.key,
  });

  final CaregiverProfile profile;
  final VoidCallback? onViewStatements;
  final ValueChanged<Payout>? onRetryPayout;

  static String _formatAmount(double value) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Earnings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceLight,
          ),
        ),
        const SizedBox(height: 12),
        // Earnings Summary Card (Styled like _EarningsCard in Caregiver Profile)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowestLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.outlineVariantLight.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '৳${_formatAmount(profile.totalEarned)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Total Earned',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariantLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => BlocProvider(
                          create: (_) => CaregiverEarningsCubit(),
                          child: const CaregiverEarningsView(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View Earnings History',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
