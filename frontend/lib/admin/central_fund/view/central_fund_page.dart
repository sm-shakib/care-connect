import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_client.dart';

import '../cubit/central_fund_cubit.dart';
import '../cubit/central_fund_state.dart';
import '../data/repositories/central_fund_repository.dart';
import '../models/central_fund_models.dart';
import 'widgets/aid_request_card.dart';
import 'widgets/bento_grid.dart';
import 'widgets/donation_tile.dart';
import 'widgets/transaction_tile.dart';

/// Content body for the Central Fund screen.
class CentralFundPage extends StatelessWidget {
  const CentralFundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CentralFundCubit(CentralFundRepository(ApiClient()))..loadData(),
      child: BlocBuilder<CentralFundCubit, CentralFundState>(
        builder: (context, state) {
          if (state is CentralFundLoading && state.selectedTabIndex == 0) {
            return const Center(child: CircularProgressIndicator());
          }
          
          FundStats? stats;
          List<DonationModel> donations = [];
          List<AidRequestModel> requests = [];
          List<TransactionModel> transactions = [];

          if (state is CentralFundLoaded) {
            stats = state.stats;
            donations = state.donations;
            requests = state.requests;
            
            // Generate some mock transactions from donations/requests for now
            // since we don't have a separate transaction endpoint yet
            transactions = [
              ...donations.map((d) => TransactionModel(
                    title: d.donorName,
                    subtitle: "Donation • ${d.date.split('T')[0]}",
                    amount: "+ ${d.amount}",
                    status: "COMPLETED",
                    type: TransactionType.donation,
                    transactionId: d.transactionId,
                  )),
              ...requests
                  .where((r) => r.status == "disbursed")
                  .map((r) => TransactionModel(
                        title: r.requesterName,
                        subtitle: "Disbursement • ${r.date.split('T')[0]}",
                        amount: "- ${r.amount}",
                        status: "COMPLETED",
                        type: TransactionType.disbursement,
                        transactionId: "AID-${r.id}",
                      )),
            ];
          }

          return RefreshIndicator(
            onRefresh: () => context.read<CentralFundCubit>().loadData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  BentoGrid(stats: stats),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildTabButton(context,
                          title: "Donations",
                          index: 0,
                          currentIndex: state.selectedTabIndex),
                      _buildTabButton(context,
                          title: "Aid Requests",
                          index: 1,
                          currentIndex: state.selectedTabIndex),
                      _buildTabButton(context,
                          title: "Transactions",
                          index: 2,
                          currentIndex: state.selectedTabIndex),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state is CentralFundError)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                    )
                  else
                    IndexedStack(
                      index: state.selectedTabIndex,
                      children: [
                        donations.isEmpty
                            ? const _EmptyState(message: "No donations yet")
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: donations.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, i) =>
                                    DonationTile(donation: donations[i]),
                              ),
                        requests.isEmpty
                            ? const _EmptyState(message: "No aid requests yet")
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: requests.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, i) =>
                                    AidRequestCard(request: requests[i]),
                              ),
                        transactions.isEmpty
                            ? const _EmptyState(message: "No transactions yet")
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: transactions.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, i) =>
                                    TransactionTile(tx: transactions[i]),
                              ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabButton(BuildContext context,
      {required String title, required int index, required int currentIndex}) {
    // ... no changes here ...
    final bool isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<CentralFundCubit>().changeTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive
                    ? const Color(0xFF006B5F)
                    : const Color(0xFFBACAC5),
                width: isActive ? 3.0 : 1.0,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  isActive ? const Color(0xFF006B5F) : const Color(0xFF3C4A46),
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
