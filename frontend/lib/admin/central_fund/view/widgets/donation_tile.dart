import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import '../../../family_member_detail/view/family_member_detail_page.dart';
import '../../../elderly_detail/view/elderly_detail_page.dart';
import '../../models/central_fund_models.dart';

class DonationTile extends StatelessWidget {
  final DonationModel donation;

  const DonationTile({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          if (donation.donorRole == 'elder') {
            Navigator.of(context).push(
              ElderlyDetailPage.route(userId: donation.donorId),
            );
          } else {
            Navigator.of(context).push(
              FamilyMemberDetailPage.route(userId: donation.donorId),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBACAC5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.paleMint,
                    backgroundImage: donation.imageUrl.isNotEmpty
                        ? NetworkImage(donation.imageUrl)
                        : null,
                    child: donation.imageUrl.isEmpty
                        ? const Icon(Icons.person, color: AppColors.darkTeal)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(donation.donorName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${donation.date} • ${donation.paymentMethod}',
                          style: const TextStyle(
                              color: Color(0xFF3C4A46), fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(donation.amount,
                      style: const TextStyle(
                          color: Color(0xFF006B5F),
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006B5F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('SUCCESS',
                        style: TextStyle(
                            color: Color(0xFF006B5F),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
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
