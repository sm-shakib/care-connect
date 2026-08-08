import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/elderly/dashboard/cubit/dashboard_cubit.dart';
import 'package:frontend/elderly/dashboard/cubit/dashboard_state.dart';
import 'package:frontend/family/models/binding_request.dart';
import 'package:frontend/theme/app_colors.dart';

class BindingRequestsPage extends StatelessWidget {
  const BindingRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Family Requests'),
        centerTitle: true,
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final requests = state.bindingRequests
              .where((r) => r.status == BindingStatus.pending)
              .toList();

          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_email_read_outlined,
                      size: 64, color: AppColors.outlineVariantLight),
                  SizedBox(height: 16),
                  Text(
                    'No pending requests.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariantLight,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.outlineVariantLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.paleMint,
                            child: Icon(Icons.family_restroom,
                                color: AppColors.darkTeal),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.familyName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurfaceLight,
                                  ),
                                ),
                                Text(
                                  'wants to add you as their ${request.relationship}',
                                  style: const TextStyle(
                                    color: AppColors.onSurfaceVariantLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _handleRequest(
                                  context, request.id, BindingStatus.rejected),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.warningRed,
                                side: const BorderSide(
                                    color: AppColors.warningRed),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleRequest(
                                  context, request.id, BindingStatus.accepted),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkTeal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Accept'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleRequest(
      BuildContext context, String requestId, BindingStatus newStatus) {
    context.read<DashboardCubit>().updateRequestStatus(requestId, newStatus);

    final message = newStatus == BindingStatus.accepted
        ? 'Request accepted successfully!'
        : 'Request declined.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: newStatus == BindingStatus.accepted
            ? AppColors.darkTeal
            : AppColors.warningRed,
      ),
    );
  }
}
