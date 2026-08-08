import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/theme/app_colors.dart';
import '../cubit/caregiver_request_cubit.dart';
import '../cubit/caregiver_request_state.dart';
import '../../models/booking_request.dart';

class PreviousBookingRequestsPage extends StatelessWidget {
  const PreviousBookingRequestsPage({super.key});

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
        title: Text(
          context.l10n.previousRequestsLabel,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
      ),
      body: BlocBuilder<CaregiverRequestCubit, CaregiverRequestState>(
        builder: (context, state) {
          final pastRequests = state.pastRequests;

          if (pastRequests.isEmpty) {
            return Center(
              child: Text(
                context.l10n.noPreviousRequestsFound,
                style: const TextStyle(color: AppColors.onSurfaceVariantLight),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: pastRequests.length,
            itemBuilder: (context, index) {
              final request = pastRequests[index];
              final isAccepted = request.status == BookingRequestStatus.accepted;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariantLight.withValues(alpha: 0.5)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  // leading: CircleAvatar(
                  //   backgroundColor: AppColors.paleMint,
                  //   backgroundImage: NetworkImage(request.elderImageUrl),
                  // ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.paleMint,
                    child: Icon(
                      request.elderGender == 'Male' ? Icons.man : Icons.woman,
                      color: AppColors.darkTeal,
                    ),
                  ),
                  title: Text(
                    request.elderName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.requestedByLabel(request.requesterName ?? 'User')),
                      const SizedBox(height: 4),
                      Text(
                        request.periodLabel ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAccepted
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAccepted ? context.l10n.acceptedStatusLabel : context.l10n.rejectedStatusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isAccepted ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
