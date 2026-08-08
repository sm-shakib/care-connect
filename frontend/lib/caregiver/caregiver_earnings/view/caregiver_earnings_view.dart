import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:frontend/theme/app_colors.dart';
import '../cubit/caregiver_earnings_cubit.dart';
import '../cubit/caregiver_earnings_state.dart';
import '../../models/earnings_record.dart';

class CaregiverEarningsView extends StatelessWidget {
  const CaregiverEarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFEFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(color: AppColors.outlineVariantLight),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Earnings History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
      ),
      body: BlocBuilder<CaregiverEarningsCubit, CaregiverEarningsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkTeal));
          }

          if (state.earnings.isEmpty) {
            return const Center(
              child: Text(
                'No earnings records found.',
                style: TextStyle(color: AppColors.onSurfaceVariantLight),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: state.earnings.length + 1, // +1 for the total summary card
            itemBuilder: (context, index) {
              if (index == 0) {
                return _TotalEarningsCard(total: state.totalEarnings);
              }
              return _EarningsTile(record: state.earnings[index - 1]);
            },
          );
        },
      ),
    );
  }
}

class _TotalEarningsCard extends StatelessWidget {
  const _TotalEarningsCard({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkTeal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkTeal.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Earnings',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '৳ ${NumberFormat('#,##,###').format(total)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsTile extends StatelessWidget {
  const _EarningsTile({required this.record});
  final EarningsRecord record;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariantLight.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.paleMint.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.payments_outlined, color: AppColors.darkTeal),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '৳ ${NumberFormat('#,###').format(record.amount)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceLight,
              ),
            ),
            Text(
              dateFormat.format(record.date),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariantLight,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Received from: ${record.fromWho}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Patient: ${record.patientName}',
                style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariantLight),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppColors.outlineLight),
                  const SizedBox(width: 4),
                  Text(
                    record.paymentMethod,
                    style: const TextStyle(fontSize: 12, color: AppColors.outlineLight),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
