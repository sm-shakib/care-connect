import 'package:flutter/material.dart';
import 'package:frontend/caregiver/caregiver_details/view/caregiver_details_page.dart';
import 'package:frontend/caregiver/data/caregiver_dummy_data.dart';
import 'package:frontend/theme/app_colors.dart';

class CaregiverStatusCard extends StatelessWidget {
  const CaregiverStatusCard({
    required this.caregiverName,
    required this.onTap,
    super.key,
  });

  final String caregiverName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Attempt to find the caregiver in the dummy data to show details
    final caregiver = caregiverList.firstWhere(
      (c) => c.name == caregiverName,
      orElse: () => caregiverList.first,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => CaregiverDetailsPage(caregiver: caregiver),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.paleMint,
                backgroundImage: caregiver.imageUrl.isNotEmpty
                    ? NetworkImage(caregiver.imageUrl)
                    : null,
                child: caregiver.imageUrl.isEmpty
                    ? const Icon(
                        Icons.medical_services,
                        color: AppColors.primaryLight,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Caregiver: $caregiverName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: AppColors.primaryLight,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'On Duty Now',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.outlineLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
