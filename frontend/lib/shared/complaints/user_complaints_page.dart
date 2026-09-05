import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'user_complaints_cubit.dart';
import 'user_complaint_model.dart';

class UserComplaintsPage extends StatelessWidget {
  const UserComplaintsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (context) => UserComplaintsCubit()..loadComplaints(),
        child: const UserComplaintsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        title: const Text(
          'My Complaints',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkTeal),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(bottom: BorderSide(color: AppColors.outlineVariantLight)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<UserComplaintsCubit, UserComplaintsState>(
        builder: (context, state) {
          if (state.status == UserComplaintsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == UserComplaintsStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Failed to load complaints: ${state.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<UserComplaintsCubit>().loadComplaints(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.complaints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 80, color: AppColors.outlineVariantLight),
                  const SizedBox(height: 16),
                  const Text(
                    'No complaints filed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariantLight),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You haven\'t reported any issues yet.',
                    style: TextStyle(color: AppColors.onSurfaceVariantLight),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.complaints.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _ComplaintListItem(complaint: state.complaints[index]);
            },
          );
        },
      ),
    );
  }
}

class _ComplaintListItem extends StatelessWidget {
  const _ComplaintListItem({required this.complaint});
  final UserComplaint complaint;

  @override
  Widget build(BuildContext context) {
    final isResolved = complaint.status == UserComplaintStatus.resolved;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariantLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Against: ${complaint.caregiverName}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _StatusBadge(status: complaint.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM d, yyyy • h:mm a').format(complaint.createdAt),
            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight),
          ),
          const Divider(height: 24),
          Text(
            'Category: ${complaint.category}',
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkTeal),
          ),
          const SizedBox(height: 4),
          Text(
            complaint.description,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          if (complaint.resolutionFeedback != null && complaint.resolutionFeedback!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.paleMint.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.feedback_outlined, size: 16, color: AppColors.primaryLight),
                      SizedBox(width: 8),
                      Text(
                        'Admin Feedback',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    complaint.resolutionFeedback!,
                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final UserComplaintStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case UserComplaintStatus.pending:
        color = Colors.orange;
        label = 'Pending';
      case UserComplaintStatus.underReview:
        color = Colors.blue;
        label = 'Reviewing';
      case UserComplaintStatus.resolved:
        color = Colors.green;
        label = 'Resolved';
      case UserComplaintStatus.dismissed:
        color = Colors.grey;
        label = 'Dismissed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
