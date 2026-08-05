import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver_signup/caregiver_signup.dart';
import 'package:frontend/family/cubit/family_dashboard_cubit.dart';
import 'package:frontend/family/models/elder.dart';
import 'package:frontend/theme/app_colors.dart';
import '../../models/caregiver.dart';


const List<CaregiverDocumentType> _kRequiredDocuments = [
  CaregiverDocumentType.nationalId,
  CaregiverDocumentType.certificate,
  CaregiverDocumentType.policeClearance,
];

class CaregiverDetailsPage extends StatelessWidget {
  final Caregiver caregiver;
  final Elder? bookingForElder;

  const CaregiverDetailsPage({
    super.key,
    required this.caregiver,
    this.bookingForElder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          "Caregiver Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile Section with Gender Fallback
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.paleMint,
                    backgroundImage: caregiver.imageUrl.isNotEmpty
                        ? NetworkImage(caregiver.imageUrl)
                        : null,
                    child: caregiver.imageUrl.isEmpty
                        ? Icon(
                      caregiver.gender == 'Male' ? Icons.man : Icons.woman,
                      size: 60,
                      color: AppColors.primaryLight,
                    )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    caregiver.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceLight,
                    ),
                  ),
                  Text(
                    caregiver.profession,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.onSurfaceVariantLight,
                    ),
                  ),
                  if (caregiver.isVerified)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            'Verified Professional',
                            style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                _buildStatItem(Icons.star, "Rating", caregiver.rating.toString(),
                    Colors.amber),
                _buildStatItem(Icons.work, "Exp", "${caregiver.experience} yrs",
                    AppColors.primaryLight),
                _buildStatItem(Icons.payments, "Rate",
                    "${caregiver.hourlyRate} ৳/hr", Colors.green),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Caregiver Information",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepTrustBlue),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              caregiver.gender == 'Male' ? Icons.man : Icons.woman,
              "Gender",
              caregiver.gender,
            ),
            _buildInfoRow(
              Icons.event_available_outlined,
              "Availability",
              caregiver.availabilityType,
            ),

            const SizedBox(height: 25),

            const Text(
              "Verified Documents",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepTrustBlue),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowestLight,
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
              child: Column(
                children: [
                  for (var i = 0; i < _kRequiredDocuments.length; i++) ...[
                    _buildDocumentRow(_kRequiredDocuments[i], caregiver.isVerified),
                    if (i != _kRequiredDocuments.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Specialties",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepTrustBlue),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: caregiver.specialties
                  .map((e) => Chip(
                label: Text(e),
                backgroundColor: AppColors.paleMint,
                side: BorderSide.none,
              ))
                  .toList(),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _handleBooking(context),
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.onSurfaceVariantLight, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryLight, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariantLight)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(CaregiverDocumentType type, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.hourglass_top,
            size: 20,
            color: isVerified ? Colors.green : Colors.amber.shade800,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              type.label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            isVerified ? 'Verified' : 'Pending Review',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isVerified ? Colors.green : Colors.amber.shade800,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBooking(BuildContext context) {
    if (bookingForElder != null) {
      _showSuccessDialog(context, bookingForElder!);
    } else {
      _showElderSelectionDialog(context);
    }
  }

  void _showElderSelectionDialog(BuildContext pageContext) {
    final cubit = pageContext.read<FamilyDashboardCubit>();
    final elders = cubit.state.elders;

    showDialog(
      context: pageContext,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Book for which Elder?', textAlign: TextAlign.center),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: elders.length,
              itemBuilder: (context, index) {
                final elder = elders[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.paleMint,
                    backgroundImage: elder.imageUrl.isNotEmpty ? NetworkImage(elder.imageUrl) : null,
                    child: elder.imageUrl.isEmpty
                        ? Icon(elder.gender == 'Male' ? Icons.man : Icons.woman, color: AppColors.primaryLight)
                        : null,
                  ),
                  title: Text(elder.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(elder.relationship),
                  onTap: () {
                    Navigator.pop(dialogContext); // Close selection dialog
                    _showSuccessDialog(pageContext, elder);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext pageContext, Elder elder) {
    final cubit = pageContext.read<FamilyDashboardCubit>();

    showDialog(
      context: pageContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                const Text(
                  "Booking Confirmed!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  "You have successfully booked\n${caregiver.name} for ${elder.name}.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.onSurfaceVariantLight),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      // Actually add the caregiver to the elder's list in the state
                      cubit.addCaregiverToElder(elder.id, caregiver.name);

                      Navigator.pop(dialogContext); // Close dialog
                      Navigator.pop(pageContext); // Close details page
                    },
                    child: const Text("Done"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}