import 'package:flutter/material.dart';
import 'package:frontend/admin/central_fund/data/repositories/central_fund_repository.dart';
import 'package:frontend/admin/central_fund/models/central_fund_models.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/theme/app_colors.dart';

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

  final Color primary = const Color(0xFF006B5F);
  final Color onSurfaceVariant = const Color(0xFF3C4A46);
  final Color outlineVariant = const Color(0xFFBACAC5);
  final Color surfaceLowest = const Color(0xFFFFFFFF);

  final List<Map<String, dynamic>> availableCaregivers = [
    {'name': 'Nurse Salma Begum', 'experience': '5 Years', 'fee': '৳ 2,500'},
    {
      'name': 'Caregiver Jamal Hossain',
      'experience': '3 Years',
      'fee': '৳ 2,000'
    },
    {'name': 'Rahima Khatun', 'experience': '1 Year', 'fee': '৳ 500'},
  ];

  int? selectedCaregiverIndex;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                  _buildDetailRow(
                    'Caregiver Type Needed', 
                    widget.request.caregiverType,
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Reason for Assistance',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7A76)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.request.reason,
                    style: TextStyle(
                      fontSize: 14,
                      color: onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Supporting Documents',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7A76)),
                  ),
                  const SizedBox(height: 8),
                  if (widget.request.documentUrl != null)
                    Container(
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
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
            const Text(
              'Allocate Caregiver',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(availableCaregivers.length, (index) {
              final caregiver = availableCaregivers[index];
              final isSelected = selectedCaregiverIndex == index;
              return GestureDetector(
                onTap: () => setState(() => selectedCaregiverIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? primary.withValues(alpha: 0.05) : surfaceLowest,
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
                        child: Icon(Icons.person, color: primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              caregiver['name'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${caregiver['experience']} Experience',
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
                            caregiver['fee'].toString(),
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cost to Family:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '৳ 0',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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
                        ? availableCaregivers[selectedCaregiverIndex!]['fee']
                            .toString()
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selectedCaregiverIndex == null || _isLoading)
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
                          'Approve & Allocate Caregiver',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleApproval() async {
    final feeStr =
        availableCaregivers[selectedCaregiverIndex!]['fee'].toString();
    final fee =
        double.parse(feeStr.replaceAll('৳', '').replaceAll(',', '').trim());

    setState(() => _isLoading = true);
    try {
      await _repository.reviewAidRequest(
        widget.request.id,
        status: 'disbursed',
        approvedAmount: fee,
        notes:
            'Assigned ${availableCaregivers[selectedCaregiverIndex!]['name']}',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
