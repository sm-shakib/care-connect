import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/admin/central_fund/data/repositories/central_fund_repository.dart';
import 'package:frontend/admin/central_fund/models/central_fund_models.dart';
import 'package:frontend/caregiver/data/repositories/caregiver_repository.dart';
import 'package:frontend/caregiver/models/caregiver.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AidRequestReviewPage extends StatefulWidget {
  const AidRequestReviewPage({
    required this.request,
    super.key,
  });

  final AidRequestModel request;

  @override
  State<AidRequestReviewPage> createState() => _AidRequestReviewPageState();
}

class _AidRequestReviewPageState extends State<AidRequestReviewPage> {
  final CentralFundRepository _repository = CentralFundRepository(ApiClient());
  final CaregiverRepository _caregiverRepo = CaregiverRepository();

  final Color primary = const Color(0xFF006B5F);
  final Color onSurfaceVariant = const Color(0xFF3C4A46);
  final Color outlineVariant = const Color(0xFFBACAC5);
  final Color surfaceLowest = const Color(0xFFFFFFFF);

  List<Caregiver> verifiedCaregivers = [];
  FundStats? _fundStats;
  int? selectedCaregiverIndex;
  bool _isLoading = false;
  bool _isFetchingData = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadInitialData());
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        _caregiverRepo.getCaregivers(),
        _repository.getFundStats(),
      ]);

      if (mounted) {
        setState(() {
          final allCaregivers = results[0] as List<Caregiver>;
          verifiedCaregivers =
              allCaregivers.where((c) => c.isVerified).toList();
          _fundStats = results[1] as FundStats;
          _isFetchingData = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _isFetchingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCaregiver = selectedCaregiverIndex != null
        ? verifiedCaregivers[selectedCaregiverIndex!]
        : null;

    final hasInsufficientFunds = selectedCaregiver != null &&
        _fundStats != null &&
        selectedCaregiver.hourlyRate > _fundStats!.balance;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        leadingWidth: 40,
        titleSpacing: 0,
        iconTheme: const IconThemeData(
          color: AppColors.primaryLight,
        ),
        title: const Text(
          'Review Assistance Request',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: surfaceLowest,
        foregroundColor: const Color(0xFF1A1C1C),
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: outlineVariant),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: REQUEST DETAILS ---
            const Text(
              'Request Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Requester', widget.request.requesterName),
                  const Divider(height: 24),
                  _buildDetailRow('Service Schedule', _formatSchedule()),
                  const Divider(height: 24),
                  const Text(
                    'Reason for Assistance',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7A76)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.request.reason,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black, // More black as requested
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Supporting Documents',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7A76)),
                  ),
                  const SizedBox(height: 8),
                  if (widget.request.documentUrl != null &&
                      widget.request.documentUrl!.isNotEmpty)
                    InkWell(
                      onTap: () async {
                        final url = Uri.parse(widget.request.documentUrl!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attach_file, size: 16, color: primary),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.request.documentUrl!.split('/').last,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Text(
                      'No documents attached',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- SECTION 2: CAREGIVER ALLOCATION ---
            const Text(
              'Allocate Caregiver',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_isFetchingData)
              const Center(child: CircularProgressIndicator())
            else if (verifiedCaregivers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No verified caregivers available.'),
              )
            else
              ...List.generate(verifiedCaregivers.length, (index) {
                final caregiver = verifiedCaregivers[index];
                final isSelected = selectedCaregiverIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedCaregiverIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primary.withValues(alpha: 0.05)
                          : surfaceLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? primary : outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: primary.withValues(alpha: 0.2),
                          backgroundImage: caregiver.imageUrl.isNotEmpty
                              ? NetworkImage(caregiver.imageUrl)
                              : null,
                          child: caregiver.imageUrl.isEmpty
                              ? Icon(Icons.person, color: primary)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                caregiver.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${caregiver.experience} Years Experience',
                                style: TextStyle(
                                  color: onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Fee (Covered)',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7A76),
                              ),
                            ),
                            Text(
                              '৳ ${caregiver.hourlyRate}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceLowest,
          border: Border(top: BorderSide(color: outlineVariant)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Central Fund Balance:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '৳ ${_fundStats?.balance.toStringAsFixed(0) ?? "0"}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006B5F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Deducted from Central Fund:',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    selectedCaregiverIndex != null
                        ? '৳ ${verifiedCaregivers[selectedCaregiverIndex!].hourlyRate}'
                        : '৳ 0',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (hasInsufficientFunds)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Insufficient funds in Central Fund to cover this caregiver.',
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _showDeclineSheet,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: (selectedCaregiverIndex == null ||
                              _isLoading ||
                              hasInsufficientFunds)
                          ? null
                          : _handleApproval,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Approve & Allocate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeclineSheet() {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Reason for Decline',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please provide a reason for declining this assistance request. This will be visible to the elder.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter reason here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _handleDecline(controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Confirm Decline',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDecline(String reason) async {
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for decline')),
      );
      return;
    }

    Navigator.pop(context); // Close sheet
    setState(() => _isLoading = true);

    try {
      await _repository.reviewAidRequest(
        widget.request.id,
        status: 'rejected',
        notes: reason,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request declined successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatSchedule() {
    final start = widget.request.serviceStartDate != null
        ? DateFormat('MMM d').format(DateTime.parse(widget.request.serviceStartDate!))
        : 'TBD';
    final end = widget.request.serviceEndDate != null
        ? DateFormat('MMM d, yyyy').format(DateTime.parse(widget.request.serviceEndDate!))
        : 'TBD';
    final days = widget.request.daysOfWeek ?? 'Everyday';
    final timing = (widget.request.dailyTimingStart != null && widget.request.dailyTimingEnd != null)
        ? '${widget.request.dailyTimingStart!.substring(0, 5)} - ${widget.request.dailyTimingEnd!.substring(0, 5)}'
        : 'Flexible';

    return '$start - $end\n$days ($timing)';
  }

  Future<void> _handleApproval() async {
    final caregiver = verifiedCaregivers[selectedCaregiverIndex!];
    final fee = caregiver.hourlyRate.toDouble();

    setState(() => _isLoading = true);
    try {
      await _repository.reviewAidRequest(
        widget.request.id,
        status: 'disbursed',
        approvedAmount: fee,
        notes: 'Assigned ${caregiver.name}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Caregiver assigned! Fee will be routed from Central Fund.',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e is DioException && e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map && data.containsKey('detail')) {
            errorMessage = data['detail'].toString();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7A76)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
