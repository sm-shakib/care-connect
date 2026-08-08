import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/central_fund_cubit.dart';
import '../cubit/central_fund_state.dart';
import '../models/central_fund_models.dart';
import 'widgets/aid_request_card.dart';
import 'widgets/bento_grid.dart';
import 'widgets/donation_tile.dart';
import 'widgets/transaction_tile.dart';

/// Content body for the Central Fund screen.
class CentralFundPage extends StatelessWidget {
  const CentralFundPage({super.key});

  final List<DonationModel> donations = const [
    DonationModel(
        donorId: "3",
        donorName: "Zayan Ahmed",
        date: "12 Oct 2023",
        paymentMethod: "Bkash",
        amount: "৳ 5,000",
        imageUrl:
            "https://static.vecteezy.com/system/resources/thumbnails/001/840/612/small/picture-profile-icon-male-icon-human-or-people-sign-and-symbol-free-vector.jpg"),
    DonationModel(
        donorId: "4",
        donorName: "Mrs. Selina Rahman",
        date: "11 Oct 2023",
        paymentMethod: "Bank Transfer",
        amount: "৳ 25,00",
        imageUrl:
            "https://static.vecteezy.com/system/resources/thumbnails/001/840/612/small/picture-profile-icon-male-icon-human-or-people-sign-and-symbol-free-vector.jpg"),
    DonationModel(
        donorId: "5",
        donorName: "Karim Ullah",
        date: "10 Oct 2023",
        paymentMethod: "Card",
        amount: "৳ 1,200",
        imageUrl:
            "https://static.vecteezy.com/system/resources/thumbnails/001/840/612/small/picture-profile-icon-male-icon-human-or-people-sign-and-symbol-free-vector.jpg"),
  ];

  final List<AidRequestModel> requests = const [
    AidRequestModel(
        requesterName: "Abdur Rahim",
        requestTitle: "Medical Assistance Request",
        note:
            '"Requires urgent medication for post-operative care following hip surgery."',
        date: "08 Oct",
        amount: "৳ 12,500",
        status: "PENDING"),
    AidRequestModel(
        requesterName: "Fatima Begum",
        requestTitle: "Daily Needs Subsidy",
        note:
            '"Monthly grocery support for elderly widow living alone in Mirpur area."',
        date: "05 Oct",
        amount: "৳ 4,500",
        status: "APPROVED"),
  ];

  final List<TransactionModel> transactions = const [
    TransactionModel(
        title: "Fatima Begum",
        subtitle: "Disbursement • 12 Oct",
        amount: "- ৳ 1,500",
        status: "COMPLETED",
        type: TransactionType.disbursement),
    TransactionModel(
        title: "Zayan Ahmed",
        subtitle: "Donation • 12 Oct",
        amount: "+ ৳ 5,000",
        status: "COMPLETED",
        type: TransactionType.donation),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CentralFundCubit(),
      child: BlocBuilder<CentralFundCubit, CentralFundState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const BentoGrid(),
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
                IndexedStack(
                  index: state.selectedTabIndex,
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: donations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          DonationTile(donation: donations[i]),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          AidRequestCard(request: requests[i]),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) =>
                          TransactionTile(tx: transactions[i]),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabButton(BuildContext context,
      {required String title, required int index, required int currentIndex}) {
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
