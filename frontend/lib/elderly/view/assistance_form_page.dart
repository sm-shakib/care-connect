import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/admin/central_fund/data/repositories/central_fund_repository.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:intl/intl.dart';

class AssistanceFormPage extends StatefulWidget {
  const AssistanceFormPage({super.key});

  @override
  State<AssistanceFormPage> createState() => _AssistanceFormPageState();
}

class _AssistanceFormPageState extends State<AssistanceFormPage> {
  final _reasonController = TextEditingController();
  PlatformFile? _selectedFile;

  // New state for service details
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final List<String> _selectedDays = [];

  final List<String> _daysOfWeek = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.darkTeal,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurfaceLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? const TimeOfDay(hour: 9, minute: 0) : const TimeOfDay(hour: 17, minute: 0),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
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
    if (_reasonController.text.isEmpty || _startDate == null || _endDate == null || _startTime == null || _endTime == null || _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all service details and reason')),
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

      if (_selectedFile != null) {
        List<int>? fileBytes = _selectedFile!.bytes?.toList();
        if (fileBytes == null && _selectedFile!.path != null) {
          fileBytes = await File(_selectedFile!.path!).readAsBytes();
        }
        if (fileBytes != null) {
          documentUrl = await authRepo.uploadFile(fileBytes, _selectedFile!.name);
        }
      }

      final repository = CentralFundRepository(ApiClient());
      
      // Format times for backend
      final startStr = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00';
      final endStr = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00';

      await repository.requestAid(
        caregiverType: 'General Assistance',
        reason: _reasonController.text,
        serviceStartDate: DateFormat('yyyy-MM-dd').format(_startDate!),
        serviceEndDate: DateFormat('yyyy-MM-dd').format(_endDate!),
        daysOfWeek: _selectedDays.join(','),
        dailyTimingStart: startStr,
        dailyTimingEnd: endStr,
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
              'Apply for a caregiver through the central fund. Admin will assess your eligibility based on your requirements.',
              style: TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('1. Duration & Schedule'),
            const SizedBox(height: 16),
            
            // Date Selection
            InkWell(
              onTap: _pickDateRange,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outlineVariantLight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, color: AppColors.darkTeal),
                    const SizedBox(width: 12),
                    Text(
                      _startDate == null 
                        ? 'Select Service Duration (Start - End)' 
                        : '${DateFormat('MMM d, yyyy').format(_startDate!)} - ${DateFormat('MMM d, yyyy').format(_endDate!)}',
                      style: TextStyle(
                        color: _startDate == null ? Colors.grey : AppColors.onSurfaceLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Days of the Week Selection
            const Text('Days of the Week', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _daysOfWeek.map((day) {
                final isSelected = _selectedDays.contains(day);
                return GestureDetector(
                  onTap: () => _toggleDay(day),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.darkTeal.withValues(alpha: 0.1)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.darkTeal
                            : AppColors.outlineVariantLight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppColors.darkTeal
                            : AppColors.onSurfaceLight,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Time Selection
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(true),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outlineVariantLight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: AppColors.darkTeal, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _startTime == null ? 'Start Time' : _startTime!.format(context),
                            style: TextStyle(fontSize: 13, color: _startTime == null ? Colors.grey : Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(false),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outlineVariantLight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_filled, color: AppColors.darkTeal, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _endTime == null ? 'End Time' : _endTime!.format(context),
                            style: TextStyle(fontSize: 13, color: _endTime == null ? Colors.grey : Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('2. Details of Assistance Needed'),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 6,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                hintText:
                    'Please describe in detail:\n1. Why you need financial assistance\n2. What type of caregiver you need (e.g., Nurse, Physiotherapist, Companion)\n3. Any specific medical conditions',
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
            _buildSectionHeader('3. Supporting Documents'),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkTeal),
    );
  }
}
