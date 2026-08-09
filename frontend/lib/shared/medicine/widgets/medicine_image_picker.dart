import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme/app_colors.dart';

/// Lets the user pick a medicine photo from the camera or device storage.
class MedicineImagePicker extends StatelessWidget {
  const MedicineImagePicker({
    required this.onImageSelected,
    this.imagePath,
    super.key,
  });

  final String? imagePath;
  final ValueChanged<String> onImageSelected;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      onImageSelected(picked.path);
    }
  }

  void _showSourcePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primaryLight,
                ),
                title: Text(
                  context.l10n.takeAPhoto,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primaryLight,
                ),
                title: Text(
                  context.l10n.chooseFromGallery,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _showSourcePicker(context),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.primaryContainerLight.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant, width: 1.6),
        ),
        clipBehavior: Clip.antiAlias,
        child: imagePath == null
            ?  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.primaryLight,
                    size: 28,
                  ),
                  SizedBox(height: 4),
                  Text(
                    context.l10n.addPhotoLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(imagePath!), fit: BoxFit.cover),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
