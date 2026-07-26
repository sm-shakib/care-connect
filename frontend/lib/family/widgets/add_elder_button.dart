import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';

class AddElderButton extends StatelessWidget {
  const AddElderButton({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTeal,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.person_add),
        label: const Text(
          'Add New Elder',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
