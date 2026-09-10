import 'package:flutter/material.dart';
import 'package:frontend/admin/caregiver_detail/view/caregiver_detail_page.dart';
import 'package:frontend/admin/elderly_detail/view/elderly_detail_page.dart';
import 'package:frontend/admin/family_member_detail/view/family_member_detail_page.dart';
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
          final donorId = donation.donorId;

          switch (donation.donorRole.toLowerCase()) {
            case 'elder':
              Navigator.of(context).push(
                ElderlyDetailPage.route(userId: donorId),
              );
            case 'family':
              Navigator.of(context).push(
                FamilyMemberDetailPage.route(userId: donorId),
              );
            case 'caregiver':
              Navigator.of(context).push(
                CaregiverDetailPage.route(userId: donorId),
              );
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile for ${donation.donorRole} coming soon'),
                ),
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
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF006B5F).withValues(alpha: 0.1),
                      backgroundImage: donation.imageUrl.isNotEmpty
                          ? NetworkImage(donation.imageUrl)
                          : null,
                      child: donation.imageUrl.isEmpty
                          ? const Icon(Icons.person, color: Color(0xFF006B5F))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            donation.donorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            '${donation.date.split('T')[0]} • ${donation.paymentMethod.toUpperCase()}',
                            style: const TextStyle(
                              color: Color(0xFF3C4A46),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
                      color: const Color(0xFF006B5F).withValues(alpha: 0.1),
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
