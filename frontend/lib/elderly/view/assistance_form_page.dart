import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/admin/central_fund/data/repositories/central_fund_repository.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/theme/app_colors.dart';

class AssistanceFormPage extends StatefulWidget {
  const AssistanceFormPage({super.key});

  @override
  State<AssistanceFormPage> createState() => _AssistanceFormPageState();
}

class _AssistanceFormPageState extends State<AssistanceFormPage> {
  final _reasonController = TextEditingController();
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  void _submitApplication() async {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your needs')),
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

    try {
      String? documentUrl;
      final authRepo = AuthRepository();

      // 1. Upload document if selected
      if (_selectedFile != null) {
        List<int>? fileBytes = _selectedFile!.bytes?.toList();
        
        // If on mobile, bytes might be null, read from path
        if (fileBytes == null && _selectedFile!.path != null) {
          fileBytes = await File(_selectedFile!.path!).readAsBytes();
        }

        if (fileBytes != null) {
          documentUrl = await authRepo.uploadFile(
            fileBytes,
            _selectedFile!.name,
          );
        }
      }

      // 2. Submit aid request
      final repository = CentralFundRepository(ApiClient());
      await repository.requestAid(
        caregiverType: 'General Assistance', // Merged into reason in UI
        reason: _reasonController.text,
        documentUrl: documentUrl,
      );
      
      if (mounted) {
        Navigator.pop(context); // Close loader
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
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
              'Apply for a caregiver through the central fund. Admin will assess your eligibility based on your reason and documents.',
              style: TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Details of Assistance Needed',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 6,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                hintText:
                    'Please describe in detail:\n1. Why you need financial assistance\n2. What type of caregiver you need (e.g., Nurse, Physiotherapist, Companion)\n3. Duration of service needed',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Make sure to mention the specific medical condition or support type required.',
              style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Supporting Documents',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDocument,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outlineVariantLight),
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedFile != null ? Colors.green.shade50 : Colors.white,
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile != null ? Icons.file_present : Icons.upload_file,
                      color: _selectedFile != null ? Colors.green : AppColors.primaryLight,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFile != null 
                          ? _selectedFile!.name 
                          : 'Upload Income Proof / Medical Necessity',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedFile != null ? Colors.green : Colors.grey,
                        fontWeight: _selectedFile != null ? FontWeight.bold : null,
                      ),
                    ),
                    if (_selectedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                          style: const TextStyle(fontSize: 11, color: Colors.green),
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
