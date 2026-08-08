import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Labeled text field used across the reminder/appointment form sheets.
class ReminderFormField extends StatelessWidget {
  const ReminderFormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.darkTeal, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

/// A tappable field styled like [ReminderFormField] that opens a picker
/// (date/time) instead of accepting free text.
class ReminderPickerField extends StatelessWidget {
  const ReminderPickerField({
    required this.label,
    required this.valueLabel,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final String valueLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.darkTeal),
                const SizedBox(width: 10),
                Text(valueLabel, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
