import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/theme/app_colors.dart';
import '../../models/booking_request.dart';
import '../cubit/caregiver_request_cubit.dart';

class BookingRequestDetailsPage extends StatelessWidget {
  const BookingRequestDetailsPage({super.key, required this.request});

  final BookingRequest request;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFEFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(color: AppColors.outlineVariantLight),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Elder Info
            Center(
              child: Column(
                children: [
                  // CircleAvatar(
                  //   radius: 50,
                  //   backgroundColor: AppColors.paleMint,
                  //   backgroundImage: NetworkImage(request.elderImageUrl),
                  // ),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.paleMint,
                    child: Icon(
                      request.elderGender == 'Male' ? Icons.man : Icons.woman,
                      size: 55,
                      color: AppColors.darkTeal,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    request.elderName ?? 'Elder',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requested by ${request.requesterName ?? 'User'}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariantLight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// Location
            _SectionTitle(title: 'Location'),
            const SizedBox(height: 12),
            _InfoBox(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: request.location ?? '',
            ),

            const SizedBox(height: 24),

            /// Booking Reason
            _SectionTitle(title: 'Booking Reason'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // color: AppColors.paleMint.withValues(alpha: 0.2),
                // borderRadius: BorderRadius.circular(18),
                // border: Border.all(color: AppColors.paleMint),
                color: AppColors.surfaceContainerLowestLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.outlineVariantLight.withValues(alpha: 0.5)),
              ),
              child: Text(
                (request.bookingReason ?? '').isNotEmpty
                    ? request.bookingReason!
                    : 'No specific reason provided.',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.onSurfaceLight,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Schedule
            _SectionTitle(title: 'Care Schedule'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowestLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.outlineVariantLight.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Service Period',
                    value: request.periodLabel ?? '',
                  ),
                  _InfoRow(
                    icon: Icons.repeat_outlined,
                    label: 'Working Days',
                    value: request.workingDaysLabel ?? '',
                  ),
                  _InfoRow(
                    icon: Icons.access_time_outlined,
                    label: 'Daily Timing',
                    value: request.timingLabel ?? '',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// Action Buttons
            if (request.status == BookingRequestStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<CaregiverRequestCubit>().rejectRequest(request.id);
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<CaregiverRequestCubit>().acceptRequest(request.id);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: request.status == BookingRequestStatus.accepted
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status == BookingRequestStatus.accepted ? 'ACCEPTED' : 'REJECTED',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: request.status == BookingRequestStatus.accepted ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
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

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariantLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.darkTeal),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: AppColors.outlineVariantLight.withValues(alpha: 0.3)),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.darkTeal),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
