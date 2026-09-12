import 'package:flutter/material.dart';
import 'package:frontend/admin/central_fund/data/repositories/central_fund_repository.dart';
import 'package:frontend/admin/central_fund/models/central_fund_models.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/theme/app_colors.dart';

class AssistanceHistoryPage extends StatefulWidget {
  const AssistanceHistoryPage({super.key});

  @override
  State<AssistanceHistoryPage> createState() => _AssistanceHistoryPageState();
}

class _AssistanceHistoryPageState extends State<AssistanceHistoryPage> {
  final _repository = CentralFundRepository(ApiClient());
  List<AidRequestModel>? _requests;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final requests = await _repository.getMyRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        title: const Text('Assistance History'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFBFEFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkTeal),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_requests == null || _requests!.isEmpty) {
      return const Center(child: Text('No assistance requests yet.'));
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _requests!.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final request = _requests![index];
          return _AssistanceCard(request: request);
        },
      ),
    );
  }
}

class _AssistanceCard extends StatelessWidget {
  const _AssistanceCard({required this.request});

  final AidRequestModel request;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(request.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
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
                'Requested: ${request.date.split('T')[0]}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              _StatusBadge(status: request.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Reason for Assistance:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
          ),
          const SizedBox(height: 4),
          Text(
            request.reason,
            style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceLight),
          ),
          if (request.assignedCaregiverName != null) ...[
            const SizedBox(height: 12),
            _AssignedCaregiverRow(
              caregiverName: request.assignedCaregiverName!,
              // Until the caregiver answers, they've been asked, not given.
              isConfirmed: request.status == 'disbursed',
            ),
          ],
          if (request.adminNotes != null && request.adminNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: request.status == 'rejected' ? Colors.red.shade50 : AppColors.paleMint.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.status == 'rejected' ? 'Reason for Decline:' : 'Admin Notes:',
                    style: TextStyle(
                      fontSize: 13, 
                      fontWeight: FontWeight.bold, 
                      color: request.status == 'rejected' ? Colors.red : AppColors.darkTeal
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.adminNotes!,
                    style: TextStyle(fontSize: 13, color: request.status == 'rejected' ? Colors.red.shade900 : AppColors.onSurfaceLight),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'awaiting_caregiver':
        return Colors.blue;
      case 'approved':
      case 'disbursed':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Who the admin has lined up for this request. Shown as "waiting" until
/// that caregiver accepts, so the elder isn't told someone is coming
/// before anyone has agreed to.
class _AssignedCaregiverRow extends StatelessWidget {
  const _AssignedCaregiverRow({
    required this.caregiverName,
    required this.isConfirmed,
  });

  final String caregiverName;
  final bool isConfirmed;

  @override
  Widget build(BuildContext context) {
    final color = isConfirmed ? AppColors.darkTeal : Colors.blue.shade700;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isConfirmed ? Icons.verified_user : Icons.hourglass_top,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isConfirmed
                  ? '$caregiverName has been assigned to you'
                  : 'Waiting for $caregiverName to accept',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    String label = status.toUpperCase();
    if (label == 'DISBURSED') label = 'APPROVED';
    if (label == 'AWAITING_CAREGIVER') label = 'ASSIGNING';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
