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
import 'package:frontend/family/view/payment/bkash_webview_page.dart';
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

class CaregiverDetailsPage extends StatefulWidget {
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

  final String? selfBookingElderName;

  @override
  State<CaregiverDetailsPage> createState() => _CaregiverDetailsPageState();
}

class _CaregiverDetailsPageState extends State<CaregiverDetailsPage> {
  late BookingRequest? _currentBooking;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dobLabel = widget.caregiver.dateOfBirth != null
        ? DateFormat('d MMM yyyy').format(widget.caregiver.dateOfBirth!)
        : '—';

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
                    backgroundImage: widget.caregiver.imageUrl.isNotEmpty
                        ? NetworkImage(widget.caregiver.imageUrl)
                        : null,
                    child: widget.caregiver.imageUrl.isEmpty
                        ? Icon(
                            widget.caregiver.gender == 'Male' ? Icons.man : Icons.woman,
                            size: 55,
                            color: AppColors.primaryLight,
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.caregiver.getName(context),
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
                  context.l10n.yearsLabel(widget.caregiver.experience),
                  AppColors.primaryLight,
                ),
                _buildStatItem(
                  Icons.payments_outlined,
                  context.l10n.rateLabel,
                  context.l10n.hourlyRateLabel(widget.caregiver.hourlyRate),
                  Colors.green,
                ),
                _buildStatItem(
                  Icons.event_available_outlined,
                  context.l10n.availabilityLabel,
                  widget.caregiver.getAvailabilityType(context),
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
                    value: widget.caregiver.phone,
                  ),
                  _InfoRow(
                    icon: Icons.mail_outline,
                    label: context.l10n.emailLabel,
                    value: widget.caregiver.email,
                  ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: context.l10n.addressLabel,
                    value: widget.caregiver.getAddress(context),
                  ),
                  _InfoRow(
                    icon: widget.caregiver.gender == 'Male'
                        ? Icons.man_outlined
                        : Icons.woman_outlined,
                    label: context.l10n.genderLabel,
                    value: widget.caregiver.getGenderLabel(context),
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
              children: widget.caregiver.specialties
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
                          widget.caregiver.getSpecialtyLabel(context, e),
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
                      fileName: widget.caregiver.documents[_kRequiredDocuments[i]] ??
                          'document.pdf',
                      onView: widget.caregiver.isVerified
                          ? () async {
                              final url =
                                  widget.caregiver.documents[_kRequiredDocuments[i]];
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

            if (widget.isAssigned) ...[
              const SizedBox(height: 25),
              _SectionTitle(title: context.l10n.scheduleTitle),
              const SizedBox(height: 12),
              _BookingScheduleCard(
                schedule: _currentBooking != null
                    ? null
                    : BookingDummyData.getScheduleForCaregiver(
                        widget.caregiver.id,
                      ),
                realBooking: _currentBooking,
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: context.l10n.paymentLabel),
              const SizedBox(height: 12),
              _AssignedBookingPaymentCard(booking: _currentBooking),
            ],

            const SizedBox(height: 32),

            /// Booking or Active Caregiver Actions
            if (!widget.isAssigned)
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
                        onPressed: _currentBooking?.paymentStatus == PaymentStatus.completed || _currentBooking?.paymentStatus == PaymentStatus.paid
                            ? null
                            : () => _showPaymentOptions(context),
                        icon: const Icon(Icons.payments_outlined),
                        label: Text(
                          _currentBooking?.paymentStatus == PaymentStatus.completed || _currentBooking?.paymentStatus == PaymentStatus.paid
                              ? 'Paid'
                              : context.l10n.paymentLabel,
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

  void _showPaymentOptions(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTeal,
                  ),
                ),
                const SizedBox(height: 20),
                _PaymentOptionTile(
                  icon: Icons.money_off_csred_outlined,
                  title: 'Pay Offline',
                  subtitle: 'Pay directly to the caregiver',
                  onTap: () {
                    Navigator.pop(context);
                    _handleOfflinePayment();
                  },
                ),
                const SizedBox(height: 12),
                _PaymentOptionTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Pay via bKash',
                  subtitle: 'Fast and secure online payment',
                  onTap: () {
                    Navigator.pop(context);
                    _handleBkashPayment();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleBkashPayment() async {
    if (_currentBooking == null) return;

    // Show loading
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD12053)),
      ),
    );

    try {
      final repo = BookingRepository();
      final bkashUrl = await repo.initializeBkashPayment(_currentBooking!.id);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        final result = await Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (_) => BkashWebViewPage(
              bkashUrl: bkashUrl,
              bookingId: _currentBooking!.id,
            ),
          ),
        );

        if (result is BookingRequest) {
          setState(() {
            _currentBooking = result;
          });
          _showPaymentSuccessDialog();
        } else if (result == true) {
          // Fallback if execute returns just true
          // You might want to re-fetch the booking here
          _showPaymentSuccessDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize bKash: $e')),
        );
      }
    }
  }

  Future<void> _handleOfflinePayment() async {
    if (_currentBooking == null) return;

    // Show loading
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = BookingRepository();
      final updatedBooking = await repo.updatePaymentStatus(
        _currentBooking!.id,
        PaymentStatus.completed,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        setState(() {
          _currentBooking = updatedBooking;
        });
        _showPaymentSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update payment: $e')),
        );
      }
    }
  }

  void _showPaymentSuccessDialog() {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payment Successful',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'The payment status has been updated to Completed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariantLight,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
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
        builder: (context) => FileComplaintSheet(
          caregiverName: widget.caregiver.name,
          caregiverId: int.tryParse(widget.caregiver.id) ?? 0,
        ),
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
    if (widget.selfBookingElderName != null) {
      // Elder booking for themselves: no elder to choose, book directly.
      final authRepo = AuthRepository();
      final profileId = await authRepo.getProfileId();
      if (profileId != null && context.mounted) {
        _showBookingOptionsSheet(
          context,
          elderName: widget.selfBookingElderName!,
          elderId: profileId,
        );
      }
    } else if (widget.bookingForElder != null) {
      _showBookingOptionsSheet(
        context,
        elderName: widget.bookingForElder!.name,
        elderId: int.tryParse(widget.bookingForElder!.id) ?? 0,
        elder: widget.bookingForElder,
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
          caregiverName: widget.caregiver.name,
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
                caregiverId: int.tryParse(widget.caregiver.id) ?? 0,
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

              final createdBooking = await repo.createBooking(request);

              if (context.mounted) {
                // Refresh the family dashboard to show the new pending request
                try {
                  context.read<FamilyDashboardCubit>().loadElders();
                } catch (_) {
                  // Not in family context
                }

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
                    pageContext.l10n.bookingRequestSentMessage(widget.caregiver.name),
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
                        // We no longer add the caregiver to the state immediately.
                        // They will appear in the "Active" list only after 
                        // they accept the request on their end.
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
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
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

class _AssignedBookingPaymentCard extends StatelessWidget {
  const _AssignedBookingPaymentCard({required this.booking});

  final BookingRequest? booking;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final amount = booking?.totalAmount ?? 0;
    final amountLabel = NumberFormat.currency(
      locale: 'en_BD',
      symbol: '৳',
      decimalDigits: 0,
    ).format(amount);
    
    final isCompleted = booking?.paymentStatus == PaymentStatus.completed || 
                        booking?.paymentStatus == PaymentStatus.paid;
    
    final statusLabel = isCompleted ? 'Completed' : 'Pending';
    final statusColor = isCompleted ? Colors.green : Colors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.paleMint.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryTeal.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 20,
                      color: AppColors.darkTeal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Payment Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amountLabel,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.paleMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.darkTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
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
