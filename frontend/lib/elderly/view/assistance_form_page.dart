import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';

class AssistanceFormPage extends StatefulWidget {
  const AssistanceFormPage({super.key});

  @override
  State<AssistanceFormPage> createState() => _AssistanceFormPageState();
}

class _AssistanceFormPageState extends State<AssistanceFormPage> {
  String? _selectedCaregiverType;
  final _reasonController = TextEditingController();
  bool _documentAttached = false;

  final List<String> _caregiverTypes = [
    'Physiotherapist',
    'Registered Nurse',
    'Home Care Assistant',
    'Dementia Care Specialist',
    'General Companion',
    'Other'
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitApplication() {
    if (_selectedCaregiverType == null || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.darkTeal),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loader
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.blue, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Application Submitted!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your request for a free caregiver has been sent to the Admin for review.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Exit form
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundLight,
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFEFC),
        title: const Text('Apply for Assistance'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assistance Request',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.deepTrustBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Apply for a specialized caregiver through the central fund. Admin will assess your eligibility.',
              style: TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
            const SizedBox(height: 32),
            DropdownButtonFormField<String>(
              value: _selectedCaregiverType,
              items: _caregiverTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCaregiverType = val),
              decoration: InputDecoration(
                labelText: 'Caregiver Type Needed',
                hintText: 'Select specialized care type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Reason for Assistance',
                alignLabelWithHint: true,
                hintText: 'Describe why you need this service for free...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Supporting Documents',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                setState(() => _documentAttached = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document attached successfully!')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outlineVariantLight),
                  borderRadius: BorderRadius.circular(12),
                  color: _documentAttached ? Colors.green.shade50 : Colors.white,
                ),
                child: Column(
                  children: [
                    Icon(
                      _documentAttached ? Icons.file_present : Icons.upload_file,
                      color: _documentAttached ? Colors.green : AppColors.primaryLight,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _documentAttached 
                          ? 'Financial_Stability_Proof.pdf' 
                          : 'Upload Income Proof / Medical Necessity',
                      style: TextStyle(
                        color: _documentAttached ? Colors.green : Colors.grey,
                        fontWeight: _documentAttached ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Submit Application',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
