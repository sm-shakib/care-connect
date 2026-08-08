import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import '../models/caregiver.dart';

class CaregiverCard extends StatelessWidget {
  final Caregiver caregiver;
  final VoidCallback onTap;

  const CaregiverCard({
    super.key,
    required this.caregiver,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Section: Avatar, Name, Specialty
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // CircleAvatar(
              //   radius: 34,
              //   backgroundColor: AppColors.paleMint,
              //   child: ClipOval(
              //     child: caregiver.imageUrl.isNotEmpty
              //         ? Image.network(
              //       caregiver.imageUrl,
              //       fit: BoxFit.cover,
              //       width: 68,
              //       height: 68,
              //       errorBuilder: (context, error, stackTrace) => Icon(
              //         caregiver.gender == 'Male'
              //             ? Icons.man
              //             : Icons.woman,
              //         color: AppColors.primaryLight,
              //         size: 38,
              //       ),
              //     )
              //         : Icon(
              //       caregiver.gender == 'Male' ? Icons.man : Icons.woman,
              //       color: AppColors.primaryLight,
              //       size: 38,
              //     ),
              //   ),
              // ),
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.paleMint,
                child: Icon(
                  caregiver.gender == 'Male' ? Icons.man : Icons.woman,
                  size: 34,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caregiver.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (caregiver.specialties.isNotEmpty)
                      Text(
                        caregiver.specialties.first,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariantLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // const SizedBox(height: 4),
                    // Text(
                    //   caregiver.profession,
                    //   style: const TextStyle(
                    //     color: AppColors.onSurfaceVariantLight,
                    //     fontSize: 15,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    // if (caregiver.isVerified)
                    //   Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 10,
                    //       vertical: 4,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: Colors.green.shade50,
                    //       borderRadius: BorderRadius.circular(30),
                    //     ),
                    //     child: const Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Icon(
                    //           Icons.verified,
                    //           size: 14,
                    //           color: Colors.green,
                    //         ),
                    //         SizedBox(width: 4),
                    //         Text(
                    //           "NID Verified",
                    //           style: TextStyle(
                    //             color: Colors.green,
                    //             fontWeight: FontWeight.w600,
                    //             fontSize: 12,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${caregiver.hourlyRate} ৳/hr",
                    style: const TextStyle(
                      color: AppColors.darkTeal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "${caregiver.distance}km",
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariantLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Specialties
          // Wrap(
          //   spacing: 8,
          //   runSpacing: 8,
          //   children: caregiver.specialties
          //       .take(2)
          //       .map(
          //         (item) => Container(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 12,
          //         vertical: 7,
          //       ),
          //       decoration: BoxDecoration(
          //         color: AppColors.surfaceContainerLight,
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       child: Text(
          //         item,
          //         style: const TextStyle(
          //           fontSize: 13,
          //         ),
          //       ),
          //     ),
          //   )
          //       .toList(),
          // ),

          /// Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "View Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
