import 'package:flutter/material.dart';
import 'package:frontend/family/models/elder.dart';
import 'package:frontend/theme/app_colors.dart';

class ElderCard extends StatelessWidget {
  const ElderCard({
    required this.elder,
    required this.onTap,
    super.key,
  });

  final Elder elder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasCaregivers = elder.caregivers.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 16),
         shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(20),
       ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        // child: Padding(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
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
          child: Row(
            children: [
              /// Elder Avatar with Robust Gender Fallback
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.paleMint,
                child: ClipOval(
                  child:
                  //     elder.imageUrl.isNotEmpty
                  //     ? Image.network(
                  //         elder.imageUrl,
                  //         fit: BoxFit.cover,
                  //         width: 60,
                  //         height: 60,
                  //         errorBuilder: (context, error, stackTrace) => Icon(
                  //           elder.gender == 'Male' ? Icons.man : Icons.woman,
                  //           size: 34,
                  //           color: AppColors.primaryLight,
                  //         ),
                  //       )
                  //     :
                        Icon(
                          elder.gender == 'Male' ? Icons.man : Icons.woman,
                          size: 34,
                          color: AppColors.primaryLight,
                        ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Name
                    Text(
                      elder.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceLight,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${elder.relationship} • ${elder.age} years',
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariantLight,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.medical_services,
                          size: 18,
                          color: AppColors.primaryLight,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            hasCaregivers
                                ? elder.caregivers.join(', ')
                                : 'No caregiver assigned',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: hasCaregivers
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFFEDD5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        elder.healthStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: hasCaregivers
                              ? const Color(0xFF15803D)
                              : const Color(0xFFC2410C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.outlineLight,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
