import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver/caregiver_request/cubit/caregiver_request_cubit.dart';
import 'package:frontend/caregiver/caregiver_request/cubit/caregiver_request_state.dart';
import 'package:frontend/caregiver/caregiver_request/view/caregiver_request_details_page.dart';
import 'package:frontend/caregiver/caregiver_request/view/previous_caregiver_request_page.dart';
import 'package:frontend/caregiver/models/booking_request.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/theme/app_colors.dart';

class CaregiverRequestsView extends StatelessWidget {
  const CaregiverRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CaregiverRequestCubit, CaregiverRequestState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final pendingRequests = state.pendingRequests;

        return RefreshIndicator(
          onRefresh: () => context.read<CaregiverRequestCubit>().loadRequests(),
          child: Column(
            children: [
              Expanded(
                child: pendingRequests.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Text(
                                context.l10n.noNewBookingRequests,
                                style: const TextStyle(
                                  color: AppColors.onSurfaceVariantLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: pendingRequests.length,
                        itemBuilder: (context, index) {
                          return _BookingRequestCard(
                            request: pendingRequests[index],
                          );
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
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => BlocProvider.value(
                            value: context.read<CaregiverRequestCubit>(),
                            child: const PreviousBookingRequestsPage(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: Text(
                      context.l10n.previousRequestsLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkTeal,
                      side: const BorderSide(
                        color: AppColors.darkTeal,
                        width: 1.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
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
                      context.l10n.requestForElderLabel(request.elderName),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.onSurfaceLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.requestedByLabel(request.displayRequesterName),
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariantLight,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.outlineLight,
                        ),
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
