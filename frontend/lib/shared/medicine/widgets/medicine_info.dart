import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_colors.dart';
import '../models/medicine.dart';
import 'medicine_image_picker.dart';

/// Medicine info section of the add/edit medicine form: photo, name,
/// dosage, and form.
class MedicineInfo extends StatelessWidget {
  const MedicineInfo({
    required this.imagePath,
    required this.nameController,
    required this.dosageController,
    required this.form,
    required this.onImageSelected,
    required this.onFormChanged,
    super.key,
  });

  final String? imagePath;
  final TextEditingController nameController;
  final TextEditingController dosageController;
  final MedicineForm form;
  final ValueChanged<String> onImageSelected;
  final ValueChanged<MedicineForm> onFormChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primaryLight),
            const SizedBox(width: 8),
            const Text(
              'Medicine Info',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: MedicineImagePicker(
            imagePath: imagePath,
            onImageSelected: onImageSelected,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: nameController,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: 'Medicine name',
            labelStyle: const TextStyle(fontSize: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(width: 1.6),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.6),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: dosageController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: 'Dosage (e.g. 1)',
            labelStyle: const TextStyle(fontSize: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(width: 1.6),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.6),
            ),
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<MedicineForm>(
          initialValue: form,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Form',
            labelStyle: const TextStyle(fontSize: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(width: 1.6),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.6),
            ),
          ),
          items: MedicineForm.values
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(
                    option.label,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onFormChanged(value);
          },
        ),
      ],
    );
  }
}
