import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/shared/complaints/user_complaint_model.dart';
import 'package:frontend/shared/complaints/user_complaints_cubit.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:intl/intl.dart';

class CaregiverReportsPage extends StatelessWidget {
  const CaregiverReportsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (context) => UserComplaintsCubit(isCaregiverMode: true)..loadComplaints(),
        child: const CaregiverReportsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        title: const Text(
          'Service Feedback',
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
                    Text('Failed to load reports: ${state.errorMessage}'),
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
                  Icon(Icons.verified_user_outlined, size: 80, color: AppColors.outlineVariantLight),
                  const SizedBox(height: 16),
                  const Text(
                    'All clear!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariantLight),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No issues reported against your service.',
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
              return _ReportListItem(complaint: state.complaints[index]);
            },
          );
        },
      ),
    );
  }
}

class _ReportListItem extends StatelessWidget {
  const _ReportListItem({required this.complaint});
  final UserComplaint complaint;

  @override
  Widget build(BuildContext context) {
    final hasResponded = complaint.caregiverExplanation != null && 
                        complaint.caregiverExplanation!.isNotEmpty;
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
                'Reported by: ${complaint.reporterName}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _StatusBadge(status: complaint.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Reported on: ${DateFormat('MMM d, yyyy').format(complaint.createdAt)}',
            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight),
          ),
          const SizedBox(height: 12),
          Text(
            'Category: ${complaint.category}',
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkTeal, fontSize: 13),
          ),
          const SizedBox(height: 8),
          const Text(
            'Report Detail:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariantLight),
          ),
          Text(
            complaint.description,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          
          if (!hasResponded && !isResolved) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showResponseSheet(context),
                icon: const Icon(Icons.reply_outlined, size: 18),
                label: const Text('Provide Explanation'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade800,
                  side: BorderSide(color: Colors.orange.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],

          if (hasResponded) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Response:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange.shade800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    complaint.caregiverExplanation!,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],

          if (complaint.resolutionFeedback != null && complaint.resolutionFeedback!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.paleMint.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.gavel_outlined, size: 16, color: AppColors.primaryLight),
                      SizedBox(width: 8),
                      Text(
                        'Admin Resolution:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    complaint.resolutionFeedback!,
                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showResponseSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Right to Respond',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please provide your side of the story. This will be reviewed by an admin before any final decision.',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariantLight),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe what happened...',
                filled: true,
                fillColor: AppColors.surfaceContainerLowLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;
                  Navigator.pop(sheetContext);
                  await context.read<UserComplaintsCubit>().respondToComplaint(
                    complaint.id,
                    controller.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text('Submit Response', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
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
        label = 'Pending Response';
      case UserComplaintStatus.underReview:
        color = Colors.blue;
        label = 'In Review';
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
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
