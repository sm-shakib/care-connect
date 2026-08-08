import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/theme/app_colors.dart';
import '../cubit/caregiver_request_cubit.dart';
import '../cubit/caregiver_request_state.dart';
import '../../models/booking_request.dart';
import 'caregiver_request_details_page.dart';
import 'previous_caregiver_request_page.dart';

class CaregiverRequestsView extends StatelessWidget {
  const CaregiverRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CaregiverRequestCubit, CaregiverRequestState>(
      builder: (context, state) {
        final pendingRequests = state.pendingRequests;

        return Column(
          children: [
            Expanded(
              child: pendingRequests.isEmpty
                  ? const Center(
                      child: Text(
                        'No new booking requests.',
                        style: TextStyle(color: AppColors.onSurfaceVariantLight),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: pendingRequests.length,
                      itemBuilder: (context, index) {
                        return _BookingRequestCard(request: pendingRequests[index]);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<CaregiverRequestCubit>(),
                          child: const PreviousBookingRequestsPage(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text(
                    'Previous Requests',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkTeal,
                    side: const BorderSide(color: AppColors.darkTeal, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BookingRequestCard extends StatelessWidget {
  const _BookingRequestCard({required this.request});

  final BookingRequest request;

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(request.requestedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CaregiverRequestCubit>(),
                child: BookingRequestDetailsPage(request: request),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // CircleAvatar(
              //   radius: 30,
              //   backgroundColor: AppColors.paleMint,
              //   backgroundImage: NetworkImage(request.elderImageUrl),
              // ),
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.paleMint,
                child: Icon(
                  request.elderGender == 'Male' ? Icons.man : Icons.woman,
                  size: 35,
                  color: AppColors.darkTeal,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request for ${request.elderName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.onSurfaceLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'From: ${request.requesterName}',
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariantLight,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.outlineLight),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.outlineLight,
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

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
