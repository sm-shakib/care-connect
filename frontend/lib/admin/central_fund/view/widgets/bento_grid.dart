import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubit/central_fund_cubit.dart';
import '../../cubit/central_fund_state.dart';

class BentoGrid extends StatelessWidget {
  const BentoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CentralFundCubit, CentralFundState>(
      builder: (context, state) {
        final amountFmt = NumberFormat.currency(
          locale: 'en_BD',
          symbol: '৳',
          decimalDigits: 0,
        );

        return Column(
          children: [
            Row(
              children: [
                // Top-Left Card: Current Fund Balance
                Expanded(
                  child: Container(
                    height: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBACAC5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_balance_wallet,
                            color: Color(0xFF006B5F), size: 24),
                        const SizedBox(height: 8),
                        const Text(
                          'Current Fund Balance',
                          style: TextStyle(
                            color: Color(0xFF3C4A46),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            amountFmt.format(state.totalAmount),
                            style: const TextStyle(
                              color: Color(0xFF006B5F),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Top-Right Card: Total Donations
                Expanded(
                  child: Container(
                    height: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBACAC5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.volunteer_activism,
                            color: Color(0xFF006B5F), size: 24),
                        const SizedBox(height: 8),
                        const Text(
                          'Total Donations',
                          style: TextStyle(
                            color: Color(0xFF3C4A46),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            amountFmt.format(state.totalAmount),
                            style: const TextStyle(
                              color: Color(0xFF006B5F),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Bottom-Left Card: Pending Aid
                Expanded(
                  child: Container(
                    height: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBACAC5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment_late_outlined,
                            color: Color(0xFF006B5F), size: 24),
                        const SizedBox(height: 8),
                        const Text(
                          'Pending Aid',
                          style: TextStyle(
                            color: Color(0xFF3C4A46),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '0 Cases',
                            style: TextStyle(
                              color: Color(0xFF006B5F),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Bottom-Right Card: Aid Distributed
                Expanded(
                  child: Container(
                    height: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBACAC5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.handshake_outlined,
                            color: Color(0xFF006B5F), size: 24),
                        const SizedBox(height: 8),
                        const Text(
                          'Aid Distributed',
                          style: TextStyle(
                            color: Color(0xFF3C4A46),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            amountFmt.format(0),
                            style: const TextStyle(
                              color: Color(0xFF006B5F),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
