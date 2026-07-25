import 'package:flutter/material.dart';
import '../../models/central_fund_models.dart';
import './../../../../theme/app_colors.dart';

class AidRequestReviewPage extends StatefulWidget {
  final AidRequestModel request;

  const AidRequestReviewPage({super.key, required this.request});

  @override
  State<AidRequestReviewPage> createState() => _AidRequestReviewPageState();
}

class _AidRequestReviewPageState extends State<AidRequestReviewPage> {
  // Theme Colors matching CareConnect Admin
  final Color primary = const Color(0xFF006B5F);
  final Color onSurfaceVariant = const Color(0xFF3C4A46);
  final Color outlineVariant = const Color(0xFFBACAC5);
  final Color surfaceLowest = const Color(0xFFFFFFFF);

  // Mock list of available caregivers matching the requested specialty
  final List<Map<String, dynamic>> availableCaregivers = [
    {"name": "Nurse Salma Begum", "experience": "5 Years", "fee": "৳ 2,500"},
    {"name": "Caregiver Jamal Hossain", "experience": "3 Years", "fee": "৳ 2,000"},
    {"name": "Rahima Khatun", "experience": "1 Years", "fee": "৳ 5,00"},
  ];

  int? selectedCaregiverIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        leadingWidth: 40, // <--- Reduces the width of the back button container
        titleSpacing: 0,
        iconTheme: const IconThemeData(
          color: AppColors.primaryLight, // Your primary green color
        ),
        title: const Text('Review Assistance Request', style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700,color: AppColors.primaryLight),),
        backgroundColor: surfaceLowest,
        foregroundColor: const Color(0xFF1A1C1C),
        elevation: 0,
        shape: Border(bottom: BorderSide(color: outlineVariant, width: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: REQUEST DETAILS ---
            const Text('Request Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  _buildDetailRow('Caregiver Type Needed', widget.request.requestTitle),
                  const Divider(height: 24),
                  const Text('Reason for Assistance', style: TextStyle(fontSize: 12, color: Color(0xFF6B7A76))),
                  const SizedBox(height: 4),
                  Text(
                    widget.request.note,
                    style: TextStyle(fontSize: 14, color: onSurfaceVariant, fontStyle: FontStyle.italic),
                  ),
                  const Divider(height: 24),
                  const Text('Supporting Documents', style: TextStyle(fontSize: 12, color: Color(0xFF6B7A76))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), // Light green tint for document
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file, size: 16, color: primary),
                        const SizedBox(width: 8),
                        Text('Financial_Stability_Proof.pdf', style: TextStyle(fontSize: 13, color: primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- SECTION 2: CAREGIVER ALLOCATION ---
            const Text('Allocate Caregiver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    color: isSelected ? primary.withOpacity(0.05) : surfaceLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primary : outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: primary.withOpacity(0.2),
                        child: Icon(Icons.person, color: primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(caregiver["name"].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${caregiver["experience"]} Experience', style: TextStyle(color: onSurfaceVariant, fontSize: 13)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Fee (Covered)', style: TextStyle(fontSize: 10, color: Color(0xFF6B7A76))),
                          Text(caregiver["fee"].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 14)),
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

      // --- SECTION 3: BOTTOM ACTION BAR ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceLowest,
          border: Border(top: BorderSide(color: outlineVariant)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cost to Family:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const Text('৳ 0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Deducted from Central Fund:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(
                    selectedCaregiverIndex != null ? availableCaregivers[selectedCaregiverIndex!]["fee"].toString() : '৳ 0',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedCaregiverIndex == null ? null : () {
                    // TODO: Implement approval logic, update request status, and pop
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Caregiver assigned! Fee will be routed from Central Fund.')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Approve & Allocate Caregiver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7A76))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}