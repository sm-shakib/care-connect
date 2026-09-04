import 'package:flutter/material.dart';
import 'package:frontend/caregiver/caregiver_details/view/caregiver_details_page.dart';
import 'package:frontend/caregiver/data/repositories/caregiver_repository.dart';
import 'package:frontend/caregiver/models/caregiver.dart';
import 'package:frontend/theme/app_colors.dart';

class CaregiverStatusCard extends StatelessWidget {
  const CaregiverStatusCard({
    required this.caregiverName,
    this.caregiverId,
    required this.onTap,
    super.key,
  });

  final String caregiverName;
  final String? caregiverId;
  final VoidCallback onTap;

  Future<void> _handleTap(BuildContext context) async {
    if (caregiverId == null) {
      // If no ID, fallback to basic view
      final caregiver = _fallbackCaregiver(caregiverName, null);
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => CaregiverDetailsPage(
            caregiver: caregiver,
            isAssigned: true,
          ),
        ),
      );
      return;
    }

    // Show loading
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = CaregiverRepository();
      final fullCaregiver = await repo.getCaregiverById(int.parse(caregiverId!));

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => CaregiverDetailsPage(
              caregiver: fullCaregiver,
              isAssigned: true,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load caregiver profile: $e')),
        );
      }
    }
  }

  Caregiver _fallbackCaregiver(String name, String? id) {
    return Caregiver(
      id: id ?? name.replaceAll(RegExp(r'\s+'), '_'),
      name: name,
      profession: 'Caregiver',
      imageUrl: '',
      rating: 0.0,
      experience: 0,
      distance: 0.0,
      hourlyRate: 0,
      isVerified: true,
      specialties: const [],
      specializations: '',
      about: '',
      gender: 'Female',
      phone: '',
      email: '',
      address: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final caregiver = _fallbackCaregiver(caregiverName, caregiverId);

    return InkWell(
      onTap: () => _handleTap(context),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.paleMint,
              child: Icon(
                caregiver.gender == 'Male' ? Icons.man : Icons.woman,
                size: 29,
                color: AppColors.primaryLight,
              ),
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
                        'Assigned',
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
    );
  }
}
