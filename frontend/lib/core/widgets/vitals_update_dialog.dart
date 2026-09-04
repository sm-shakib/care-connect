import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'primary_pill_button.dart';

class VitalsUpdateDialog extends StatefulWidget {
  const VitalsUpdateDialog({
    required this.onSave,
    this.initialHr,
    this.initialSystolic,
    this.initialDiastolic,
    super.key,
  });

  final int? initialHr;
  final int? initialSystolic;
  final int? initialDiastolic;
  final Function(int hr, int systolic, int diastolic) onSave;

  @override
  State<VitalsUpdateDialog> createState() => _VitalsUpdateDialogState();
}

class _VitalsUpdateDialogState extends State<VitalsUpdateDialog> {
  late final TextEditingController _hrController;
  late final TextEditingController _systolicController;
  late final TextEditingController _diastolicController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hrController = TextEditingController(text: widget.initialHr?.toString());
    _systolicController = TextEditingController(text: widget.initialSystolic?.toString());
    _diastolicController = TextEditingController(text: widget.initialDiastolic?.toString());
  }

  @override
  void dispose() {
    _hrController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Update Health Vitals',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkTeal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _VitalsField(
              label: 'Heart Rate (BPM)',
              controller: _hrController,
              icon: Icons.favorite,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Blood Pressure (mmHg)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariantLight),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _VitalsField(
                    label: 'Systolic',
                    controller: _systolicController,
                    isCompact: true,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('/', style: TextStyle(fontSize: 24, color: AppColors.outlineLight)),
                ),
                Expanded(
                  child: _VitalsField(
                    label: 'Diastolic',
                    controller: _diastolicController,
                    isCompact: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            PrimaryPillButton(
              label: 'Save Vitals',
              isLoading: _isLoading,
              onPressed: () async {
                final hr = int.tryParse(_hrController.text);
                final sys = int.tryParse(_systolicController.text);
                final dia = int.tryParse(_diastolicController.text);

                if (hr != null && sys != null && dia != null) {
                  setState(() => _isLoading = true);
                  await widget.onSave(hr, sys, dia);
                  if (mounted) Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid numbers')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalsField extends StatelessWidget {
  const _VitalsField({
    required this.label,
    required this.controller,
    this.icon,
    this.color,
    this.isCompact = false,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final Color? color;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: color) : null,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isCompact ? 12 : 16),
      ),
    );
  }
}
