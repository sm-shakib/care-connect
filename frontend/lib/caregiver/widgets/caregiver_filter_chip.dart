import 'package:flutter/material.dart';

class CaregiverFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const CaregiverFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        onSelected: (_) => onTap?.call(),
        showCheckmark: false,
        label: Text(label),
        selectedColor:
        const Color(0xff00897B),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: selected
              ? const Color(0xff00897B)
              : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(24),
        ),
      ),
    );
  }
}