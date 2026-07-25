import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/central_fund_cubit.dart';
import '../cubit/central_fund_state.dart';
import '../models/central_fund_models.dart';
import 'widgets/aid_request_card.dart';
import 'widgets/bento_grid.dart';
import 'widgets/donation_tile.dart';
import 'widgets/transaction_tile.dart';
import '../../../theme/app_colors.dart';
import '../../admin_shell/admin_shell.dart';
import '../../admin_navigation.dart';

class CentralFundPage extends StatelessWidget {
  const CentralFundPage({super.key});

  // Mock data matching the design template
  final List<DonationModel> donations = const [
    DonationModel(donorName: "Zayan Ahmed", date: "12 Oct 2023", paymentMethod: "Bkash", amount: "৳ 5,000", imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuA-GcYvOr1xoyJeHPYQkjzFyAuVNsHs8qkzJtEv4NeYc9Wi7HUh48XaObqdoxkW9Im4T97j7-Kcin8_lOxBgXm31u2gs-7rSAiljoQffgccMkB0iiUfZL9YLOwpZr0jQyEKbMScRGoCgr3H4O9htZ1A6Q7bEPPq4wFrD4PsmcZ8A4D6oixp3kX1je2MJKJkxONCmXYzapKxbQ5QAz9-PMODS2d6_Ha9IzvPhFSvU0CwP3AnIXn5BgX1CNfFPvx4tSPb7t7WKS3IBuU"),
    DonationModel(donorName: "Mrs. Selina Rahman", date: "11 Oct 2023", paymentMethod: "Bank Transfer", amount: "৳ 25,000", imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuAg1SJZGKUIwEtivrjPW48FWSUDaU7dvMH8jbzBE1nDVCMAufn5jq5tWBuqdey-SY1xNlyTC1U_BHPMVjqfLd3xrQ3sM5msvREv6I8gGA6kBe4VMcLWmR3n6nvU0Oto7ie98b37-rOoS_fw_7bq02KwkxL1em7zLTcWN6Vq6c9fjxwacr0S-AySZ67ebn5CwpTtSuXYIjy9sp6m-JkZcPCjx0h-9AfTYLp0ZFZGhLqtMRkTtgs0ZiZ7WTwC4q46gr3WrjdaOjfx4Zs"),
    DonationModel(donorName: "Karim Ullah", date: "10 Oct 2023", paymentMethod: "Card", amount: "৳ 1,200", imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuCsVPShmkbRvM0pqmpB_1KdHYylrJEKquuULekaCknrs5ilrr9FsS7Q957YrCrfJx_HtlMppLiDQ2oDTmUFk0YTAwce_9jnlqxLDuchmh_pTgDjhaZz_R_JEPcwvgWwwqy2XpVZjmErao6pobUoiotJLHSZu_82KWsS-1oAexj40emQ5Ws8G2OjXev0pwIR2U18Um5CNOZMGX23cpgv962CLSXGejQ8rW_yCagtI_ULZKM41Q4tguCv41wNJVKH2Z3Pc--CB5dZ1vc"),
  ];

  final List<AidRequestModel> requests = const [
    AidRequestModel(requesterName: "Abdur Rahim", requestTitle: "Medical Assistance Request", note: '"Requires urgent medication for post-operative care following hip surgery."', date: "08 Oct", amount: "৳ 12,500", status: "PENDING"),
    AidRequestModel(requesterName: "Fatima Begum", requestTitle: "Daily Needs Subsidy", note: '"Monthly grocery support for elderly widow living alone in Mirpur area."', date: "05 Oct", amount: "৳ 4,500", status: "APPROVED"),
  ];

  final List<TransactionModel> transactions = const [
    TransactionModel(title: "Fatima Begum", subtitle: "Disbursement • 12 Oct", amount: "- ৳ 4,500", status: "COMPLETED", type: TransactionType.disbursement),
    TransactionModel(title: "Zayan Ahmed", subtitle: "Donation • 12 Oct", amount: "+ ৳ 5,000", status: "COMPLETED", type: TransactionType.donation),
    TransactionModel(title: "Bank Transfer", subtitle: "External Fetch • 11 Oct", amount: "৳ 0", status: "SYNCING", type: TransactionType.sync),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CentralFundCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9F9),
          elevation: 0,
          titleSpacing:0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryLight),
            onPressed: () {
              // Switch the shell's active tab to dashboard
              goToAdminTab(context, AdminTab.dashboard);
            },
          ),
          title: Text(
            'Central Fund',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryLight,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: AppColors.primaryLight),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<CentralFundCubit, CentralFundState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const BentoGrid(),
                  const SizedBox(height: 20),
                  // Custom Tab Bar
                  Row(
                    children: [
                      _buildTabButton(context, title: "Donations", index: 0, currentIndex: state.selectedTabIndex),
                      _buildTabButton(context, title: "Aid Requests", index: 1, currentIndex: state.selectedTabIndex),
                      _buildTabButton(context, title: "Transactions", index: 2, currentIndex: state.selectedTabIndex),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Indexed Content Views
                  IndexedStack(
                    index: state.selectedTabIndex,
                    children: [
                      // Tab 0: Donations
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: donations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => DonationTile(donation: donations[i]),
                      ),
                      // Tab 1: Aid Requests
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: requests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => AidRequestCard(request: requests[i]),
                      ),
                      // Tab 2: Transactions
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => TransactionTile(tx: transactions[i]),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, {required String title, required int index, required int currentIndex}) {
    final bool isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<CentralFundCubit>().changeTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF006B5F) : const Color(0xFFBACAC5),
                width: isActive ? 3.0 : 1.0,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? const Color(0xFF006B5F) : const Color(0xFF3C4A46),
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}