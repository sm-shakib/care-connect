import 'package:flutter/material.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/theme/app_colors.dart';

class FileComplaintSheet extends StatefulWidget {
  const FileComplaintSheet({super.key, required this.patientName});

  final String patientName;

  @override
  State<FileComplaintSheet> createState() => _FileComplaintSheetState();
}

class _FileComplaintSheetState extends State<FileComplaintSheet> {
  String? _selectedCategory;
  final _descriptionController = TextEditingController();
  bool _canSubmit = false;

  final _categories = [
    'Behavioral Issue (Elder)',
    'Behavioral Issue (Family)',
    'Payment Dispute',
    'Unsafe Working Environment',
    'Unreasonable Demands',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_validateForm);
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _selectedCategory != null && _descriptionController.text.trim().isNotEmpty;
    if (isValid != _canSubmit) {
      setState(() {
        _canSubmit = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.fileComplaintTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTeal,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.reportIssueLabel(widget.patientName),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariantLight,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.categoryLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTeal,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            items: [
              context.l10n.complaintCategoryBehaviorElder,
              context.l10n.complaintCategoryBehaviorFamily,
              context.l10n.complaintCategoryPayment,
              context.l10n.complaintCategoryUnsafeEnv,
              context.l10n.complaintCategoryUnreasonableDemands,
              context.l10n.complaintCategoryOthers,
            ]
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) {
              setState(() => _selectedCategory = val);
              _validateForm();
            },
            style: const TextStyle(fontSize: 15, color: AppColors.onSurfaceLight),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.darkTeal),
            decoration: InputDecoration(
              hintText: context.l10n.selectCategoryHint,
              hintStyle: const TextStyle(color: AppColors.onSurfaceVariantLight),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.outlineVariantLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.outlineVariantLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.darkTeal, width: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.descriptionLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTeal,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: context.l10n.describeIssueHint,
              hintStyle: const TextStyle(color: AppColors.onSurfaceVariantLight),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.outlineVariantLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.outlineVariantLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.darkTeal, width: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _canSubmit
                  ? () {
                      Navigator.pop(context);
                      _showComplaintSuccessDialog(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.redAccent.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                context.l10n.submitComplaintLabel,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComplaintSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              context.l10n.complaintSubmittedTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.complaintReceivedMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(context.l10n.closeLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
