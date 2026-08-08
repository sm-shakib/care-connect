import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:frontend/caregiver_signup/caregiver_signup.dart';
import 'package:frontend/family/cubit/family_dashboard_cubit.dart';
import 'package:frontend/family/models/elder.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/family/view/payment/caregiver_payment_page.dart';
import '../../models/caregiver.dart';
import '../../caregiver_profile/widgets/verified_document_tile.dart';
import '../../../family/widgets/booking_options_sheet.dart';
import '../../../family/widgets/file_complaint_sheet.dart';
import '../../../family/data/booking_dummy_data.dart';
import '../../../family/models/booking_schedule.dart';

const List<CaregiverDocumentType> _kRequiredDocuments = [
  CaregiverDocumentType.nationalId,
  CaregiverDocumentType.certificate,
  CaregiverDocumentType.policeClearance,
];

class CaregiverDetailsPage extends StatelessWidget {
  final Caregiver caregiver;
  final Elder? bookingForElder;
  final bool isAssigned;

  /// When set, "Book Now" books the caregiver for the current elder (the
  /// app user themselves) using this name, skipping the family-only "which
  /// elder is this for?" selection dialog. Used by the elder's own
  /// caregiver list, which has no [FamilyDashboardCubit] in the widget tree.
  final String? selfBookingElderName;

  const CaregiverDetailsPage({
    super.key,
    required this.caregiver,
    this.bookingForElder,
    this.isAssigned = false,
    this.selfBookingElderName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dobLabel = caregiver.dateOfBirth != null
        ? DateFormat('d MMM yyyy').format(caregiver.dateOfBirth!)
        : '—';

    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        title: const Text(
          "Caregiver Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkTeal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(
          bottom: BorderSide(color: AppColors.outlineVariantLight),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile Header Section
            Center(
              child: Column(
                children: [
                  // CircleAvatar(
                  //   radius: 50,
                  //   backgroundColor: AppColors.paleMint,
                  //   backgroundImage: caregiver.imageUrl.isNotEmpty
                  //       ? NetworkImage(caregiver.imageUrl)
                  //       : null,
                  //   child: caregiver.imageUrl.isEmpty
                  //       ? Icon(
                  //           caregiver.gender == 'Male' ? Icons.man : Icons.woman,
                  //           size: 55,
                  //           color: AppColors.primaryLight,
                  //         )
                  //       : null,
                  // ),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.paleMint,
                    child: Icon(
                      caregiver.gender == 'Male' ? Icons.man : Icons.woman,
                      size: 55,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    caregiver.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  // Text(
                  //   caregiver.profession,
                  //   style: TextStyle(
                  //     fontSize: 15,
                  //     color: colorScheme.onSurfaceVariant,
                  //   ),
                  // ),
                  // if (caregiver.isVerified)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 8),
                  //     child: Container(
                  //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  //       decoration: BoxDecoration(
                  //         color: Colors.blue.shade50,
                  //         borderRadius: BorderRadius.circular(30),
                  //       ),
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           const Icon(Icons.verified, color: Colors.blue, size: 14),
                  //           const SizedBox(width: 4),
                  //           Text(
                  //             'Verified Professional',
                  //             style: TextStyle(
                  //                 color: Colors.blue.shade800,
                  //                 fontSize: 12,
                  //                 fontWeight: FontWeight.bold),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Basic Stats Row
            Row(
              children: [
                // _buildStatItem(Icons.star, "Rating", caregiver.rating.toString(), Colors.amber),
                _buildStatItem(Icons.work_history_outlined, "Exp", "${caregiver.experience} yrs", AppColors.primaryLight),
                _buildStatItem(Icons.payments_outlined, "Rate", "৳${caregiver.hourlyRate}/hr", Colors.green),
                _buildStatItem(Icons.location_on_outlined, "Dist", "${caregiver.distance} km", Colors.orange),
              ],
            ),

            const SizedBox(height: 25),

            /// Professional Info Section
            _SectionTitle(title: "Caregiver Information"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone Number',
                    value: caregiver.phone,
                  ),
                  _InfoRow(
                    icon: Icons.mail_outline,
                    label: 'Email',
                    value: caregiver.email,
                  ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: caregiver.address,
                  ),
                  _InfoRow(
                    icon: caregiver.gender == 'Male' ? Icons.man_outlined : Icons.woman_outlined,
                    label: 'Gender',
                    value: caregiver.gender,
                  ),
                  _InfoRow(
                    icon: Icons.cake_outlined,
                    label: 'Date of Birth',
                    value: dobLabel,
                  ),
                  _InfoRow(
                    icon: Icons.medical_services_outlined,
                    label: 'Specializations',
                    value: caregiver.specializations,
                  ),
                  _InfoRow(
                    icon: Icons.event_available_outlined,
                    label: 'Availability',
                    value: caregiver.availabilityType,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Specializations Section
            _SectionTitle(title: "Specialties"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: caregiver.specialties
                  .map((e) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.paleMint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          e,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 25),

            /// Documents Section
            _SectionTitle(title: "Verified Documents"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _kRequiredDocuments.length; i++) ...[
                    VerifiedDocumentTile(
                      type: _kRequiredDocuments[i],
                      fileName: caregiver.documents[_kRequiredDocuments[i]] ?? 'document.pdf',
                      onView: caregiver.isVerified ? () {
                        // TODO: Show document preview
                      } : null,
                    ),
                    if (i != _kRequiredDocuments.length - 1)
                      Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ],
                ],
              ),
            ),

            if (isAssigned) ...[
              const SizedBox(height: 25),
              _SectionTitle(title: "Schedule"),
              const SizedBox(height: 12),
              _BookingScheduleCard(
                schedule: BookingDummyData.getScheduleForCaregiver(caregiver.id),
              ),
            ],

            const SizedBox(height: 32),

            /// Booking or Active Caregiver Actions
            if (!isAssigned)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
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
              )
            else
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => _showFileComplaintSheet(context),
                        icon: const Icon(Icons.report_problem_outlined, size: 20),
                        label: const Text(
                          'File Complaint',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CaregiverPaymentPage(caregiver: caregiver),
                            ),
                          );
                        },
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text(
                          'Payment',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showFileComplaintSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FileComplaintSheet(caregiverName: caregiver.name),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariantLight, fontSize: 11)),
        ],
      ),
    );
  }

  void _handleBooking(BuildContext context) {
    if (selfBookingElderName != null) {
      // Elder booking for themselves: no elder to choose, book directly.
      _showBookingOptionsSheet(context, elderName: selfBookingElderName!);
    } else if (bookingForElder != null) {
      _showBookingOptionsSheet(
        context,
        elderName: bookingForElder!.name,
        elder: bookingForElder,
      );
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
                  // leading: CircleAvatar(
                  //   backgroundColor: AppColors.paleMint,
                  //   backgroundImage: elder.imageUrl.isNotEmpty ? NetworkImage(elder.imageUrl) : null,
                  //   child: elder.imageUrl.isEmpty
                  //       ? Icon(elder.gender == 'Male' ? Icons.man : Icons.woman, color: AppColors.primaryLight)
                  //       : null,
                  // ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.paleMint,
                    child: Icon(
                      elder.gender == 'Male' ? Icons.man : Icons.woman,
                      color: AppColors.darkTeal,
                    ),
                  ),
                  title: Text(elder.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(elder.relationship),
                  onTap: () {
                    Navigator.pop(dialogContext); // Close selection dialog
                    _showBookingOptionsSheet(
                      pageContext,
                      elderName: elder.name,
                      elder: elder,
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Shows the booking form for [elderName]. [elder] should be passed
  /// whenever a real [Elder] record exists (family flow) so the resulting
  /// booking can be attached to it; leave it null for self-booking.
  void _showBookingOptionsSheet(
    BuildContext context, {
    required String elderName,
    Elder? elder,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BookingOptionsSheet(
        caregiverName: caregiver.name,
        elderName: elderName,
        onConfirm: (reason) {
          Navigator.pop(sheetContext); // Close options sheet
          _showSuccessDialog(context, elder);
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext pageContext, Elder? elder) {
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
                const Icon(Icons.hourglass_empty, color: Colors.amber, size: 80),
                const SizedBox(height: 20),
                const Text(
                  "Request Sent",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  "Your booking request for ${caregiver.name} has been sent.\n\nWaiting for approval.",
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
                      if (elder != null) {
                        // Actually add the caregiver to the elder's list in the state
                        pageContext
                            .read<FamilyDashboardCubit>()
                            .addCaregiverToElder(elder.id, caregiver.name);
                      }

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

class _BookingScheduleCard extends StatelessWidget {
  const _BookingScheduleCard({required this.schedule});

  final BookingSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Service Period',
            value: schedule.periodLabel,
          ),
          _InfoRow(
            icon: Icons.repeat_outlined,
            label: 'Working Days',
            value: schedule.workingDaysLabel,
          ),
          _InfoRow(
            icon: Icons.access_time_outlined,
            label: 'Daily Timing',
            value: schedule.timingLabel,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTeal,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.darkTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurface, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
