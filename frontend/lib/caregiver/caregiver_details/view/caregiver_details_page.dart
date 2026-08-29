import 'dart:async';
// import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver/caregiver_profile/widgets/verified_document_tile.dart';
import 'package:frontend/caregiver/data/repositories/booking_repository.dart';
import 'package:frontend/caregiver/models/booking_request.dart';
import 'package:frontend/caregiver/models/caregiver.dart';
import 'package:frontend/caregiver_signup/caregiver_signup.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/family/cubit/family_dashboard_cubit.dart';
import 'package:frontend/family/data/booking_dummy_data.dart';
import 'package:frontend/family/models/booking_schedule.dart';
import 'package:frontend/family/models/elder.dart';
import 'package:frontend/family/view/payment/caregiver_payment_page.dart';
import 'package:frontend/family/widgets/booking_options_sheet.dart';
import 'package:frontend/family/widgets/file_complaint_sheet.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

const List<CaregiverDocumentType> _kRequiredDocuments = [
  CaregiverDocumentType.nationalId,
  CaregiverDocumentType.certificate,
  CaregiverDocumentType.policeClearance,
];

class CaregiverDetailsPage extends StatelessWidget {
  const CaregiverDetailsPage({
    required this.caregiver,
    this.bookingForElder,
    this.isAssigned = false,
    this.selfBookingElderName,
    this.booking,
    super.key,
  });

  final Caregiver caregiver;
  final Elder? bookingForElder;
  final bool isAssigned;
  final BookingRequest? booking;

  /// When set, "Book Now" books the caregiver for the current elder (the
  /// app user themselves) using this name, skipping the family-only "which
  /// elder is this for?" selection dialog. Used by the elder's own
  /// caregiver list, which has no [FamilyDashboardCubit] in the widget tree.
  final String? selfBookingElderName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dobLabel = caregiver.dateOfBirth != null
        ? DateFormat('d MMM yyyy').format(caregiver.dateOfBirth!)
        : '—';

    // Calculate distance if booking context exists
    /*
    double? calculatedDistance;
    if (bookingForElder != null) {
      calculatedDistance = _calculateDistance(
        bookingForElder!.latitude,
        bookingForElder!.longitude,
        caregiver.latitude,
        caregiver.longitude,
      );
    }
    */

    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        title: Text(
          context.l10n.caregiverDetailsTitle,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.darkTeal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
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
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.paleMint,
                    backgroundImage: caregiver.imageUrl.isNotEmpty
                        ? NetworkImage(caregiver.imageUrl)
                        : null,
                    child: caregiver.imageUrl.isEmpty
                        ? Icon(
                            caregiver.gender == 'Male' ? Icons.man : Icons.woman,
                            size: 55,
                            color: AppColors.primaryLight,
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    caregiver.getName(context),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Basic Stats Row
            Row(
              children: [
                _buildStatItem(
                  Icons.work_history_outlined,
                  context.l10n.expLabel,
                  context.l10n.yearsLabel(caregiver.experience),
                  AppColors.primaryLight,
                ),
                _buildStatItem(
                  Icons.payments_outlined,
                  context.l10n.rateLabel,
                  context.l10n.hourlyRateLabel(caregiver.hourlyRate),
                  Colors.green,
                ),
                _buildStatItem(
                  Icons.event_available_outlined,
                  context.l10n.availabilityLabel,
                  caregiver.getAvailabilityType(context),
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 25),

            /// Professional Info Section
            _SectionTitle(title: context.l10n.caregiverInfoSectionTitle),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: context.l10n.phoneNumberLabel,
                    value: caregiver.phone,
                  ),
                  _InfoRow(
                    icon: Icons.mail_outline,
                    label: context.l10n.emailLabel,
                    value: caregiver.email,
                  ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: context.l10n.addressLabel,
                    value: caregiver.getAddress(context),
                  ),
                  _InfoRow(
                    icon: caregiver.gender == 'Male'
                        ? Icons.man_outlined
                        : Icons.woman_outlined,
                    label: context.l10n.genderLabel,
                    value: caregiver.getGenderLabel(context),
                  ),
                  _InfoRow(
                    icon: Icons.cake_outlined,
                    label: context.l10n.dateOfBirthLabel,
                    value: dobLabel,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Specializations Section
            _SectionTitle(title: context.l10n.specializationsLabel),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: caregiver.specialties
                  .map((e) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.paleMint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          caregiver.getSpecialtyLabel(context, e),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 25),

            /// Documents Section
            _SectionTitle(title: context.l10n.verifiedDocumentsTitle),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _kRequiredDocuments.length; i++) ...[
                    VerifiedDocumentTile(
                      type: _kRequiredDocuments[i],
                      fileName: caregiver.documents[_kRequiredDocuments[i]] ??
                          'document.pdf',
                      onView: caregiver.isVerified
                          ? () async {
                              final url =
                                  caregiver.documents[_kRequiredDocuments[i]];
                              if (url != null && url.isNotEmpty) {
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              }
                            }
                          : null,
                    ),
                    if (i != _kRequiredDocuments.length - 1)
                      Divider(
                        height: 1,
                        color: colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                  ],
                ],
              ),
            ),

            if (isAssigned) ...[
              const SizedBox(height: 25),
              _SectionTitle(title: context.l10n.scheduleTitle),
              const SizedBox(height: 12),
              _BookingScheduleCard(
                schedule: booking != null
                    ? null
                    : BookingDummyData.getScheduleForCaregiver(
                        caregiver.id,
                      ),
                realBooking: booking,
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
                  child: Text(
                    context.l10n.bookNowLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                        icon: const Icon(
                          Icons.report_problem_outlined,
                          size: 20,
                        ),
                        label: Text(
                          context.l10n.fileComplaintLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.4,
                          ),
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
                          unawaited(
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => CaregiverPaymentPage(
                                  caregiver: caregiver,
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.payments_outlined),
                        label: Text(
                          context.l10n.paymentLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
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
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FileComplaintSheet(caregiverName: caregiver.name),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
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
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurfaceVariantLight,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBooking(BuildContext context) async {
    if (selfBookingElderName != null) {
      // Elder booking for themselves: no elder to choose, book directly.
      final authRepo = AuthRepository();
      final profileId = await authRepo.getProfileId();
      if (profileId != null && context.mounted) {
        _showBookingOptionsSheet(
          context,
          elderName: selfBookingElderName!,
          elderId: profileId,
        );
      }
    } else if (bookingForElder != null) {
      _showBookingOptionsSheet(
        context,
        elderName: bookingForElder!.name,
        elderId: int.tryParse(bookingForElder!.id) ?? 0,
        elder: bookingForElder,
      );
    } else {
      _showElderSelectionDialog(context);
    }
  }

  void _showElderSelectionDialog(BuildContext pageContext) {
    final cubit = pageContext.read<FamilyDashboardCubit>();
    final elders = cubit.state.elders;

    unawaited(
      showDialog<void>(
        context: pageContext,
        builder: (dialogContext) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(pageContext.l10n.bookForWhichElderTitle,
                textAlign: TextAlign.center),
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
                      child: Icon(
                        elder.gender == 'Male' ? Icons.man : Icons.woman,
                        color: AppColors.darkTeal,
                      ),
                    ),
                    title: Text(elder.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(elder.relationship),
                    onTap: () {
                      Navigator.pop(dialogContext); // Close selection dialog
                      _showBookingOptionsSheet(
                        pageContext,
                        elderName: elder.name,
                        elderId: int.tryParse(elder.id) ?? 0,
                        elder: elder,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// Shows the booking form for [elderName]. [elder] should be passed
  /// whenever a real [Elder] record exists (family flow) so the resulting
  /// booking can be attached to it; leave it null for self-booking.
  void _showBookingOptionsSheet(
    BuildContext context, {
    required String elderName,
    required int elderId,
    Elder? elder,
  }) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => BookingOptionsSheet(
          caregiverName: caregiver.name,
          elderName: elderName,
          onConfirm: (
            startDate,
            endDate,
            daysOfWeek,
            startTime,
            endTime,
            reason,
          ) async {
            // Show loading
            showDialog<void>(
              context: sheetContext,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            try {
              final repo = BookingRepository();
              final request = BookingRequest(
                id: 0, // Assigned by server
                elderId: elderId,
                caregiverId: int.tryParse(caregiver.id) ?? 0,
                startDate: startDate,
                endDate: endDate,
                daysOfWeek: daysOfWeek,
                startTime: startTime,
                endTime: endTime,
                status: BookingStatus.pending,
                paymentStatus: PaymentStatus.pending,
                requestedAt: DateTime.now(),
                reason: reason,
              );

              await repo.createBooking(request);

              if (context.mounted) {
                Navigator.pop(sheetContext); // Close loading
                Navigator.pop(sheetContext); // Close options sheet
                _showSuccessDialog(context, elder);
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(sheetContext); // Close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to send request: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext pageContext, Elder? elder) {
    unawaited(
      showDialog<void>(
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
                    const Icon(
                    Icons.hourglass_empty,
                    color: Colors.amber,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    pageContext.l10n.requestSentTitle,
                    style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pageContext.l10n.bookingRequestSentMessage(caregiver.name),
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
                          // Actually add the caregiver to the elder's list in
                          // the state.
                          pageContext
                              .read<FamilyDashboardCubit>()
                              .addCaregiverToElder(elder.id, caregiver.name);
                        }

                        Navigator.pop(dialogContext); // Close dialog
                        Navigator.pop(pageContext); // Close details page
                      },
                      child: Text(pageContext.l10n.doneLabel),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /*
  /// Calculates the distance between two coordinates in kilometers using
  /// the Haversine formula.
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;
    return double.parse(distance.toStringAsFixed(2));
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }
  */
}

class _BookingScheduleCard extends StatelessWidget {
  const _BookingScheduleCard({this.schedule, this.realBooking});

  final BookingSchedule? schedule;
  final BookingRequest? realBooking;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final period = realBooking?.periodLabel ?? schedule?.periodLabel ?? '';
    final workingDays =
        realBooking?.workingDaysLabel ?? schedule?.workingDaysLabel ?? '';
    final timing = realBooking?.timingLabel ?? schedule?.timingLabel ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: context.l10n.servicePeriodLabel,
            value: period,
          ),
          _InfoRow(
            icon: Icons.repeat_outlined,
            label: context.l10n.workingDaysLabel,
            value: workingDays,
          ),
          _InfoRow(
            icon: Icons.access_time_outlined,
            label: context.l10n.dailyTimingLabel,
            value: timing,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

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
                bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
