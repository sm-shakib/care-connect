import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:frontend/theme/app_colors.dart';

import '../models/message_attachment.dart';

/// Bottom sheet offering the three ways to attach something to a message:
/// photos from the gallery (via `wechat_assets_picker`), a document (via
/// the existing `file_picker`, same pattern as `DocumentUploadTile`), or a
/// fresh camera photo.
class AttachmentPickerSheet {
  const AttachmentPickerSheet._();

  static Future<void> show(
    BuildContext context, {
    required void Function(List<MessageAttachment> attachments, AttachmentKind kind) onPicked,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return showModalBottomSheet<void>(
      context: context,
      // backgroundColor: colorScheme.surface,
      backgroundColor: const Color(0xFFFBFEFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              _Option(
                icon: Icons.photo_library_outlined,
                label: 'Photos',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final attachments = await _pickPhotos(context);
                  if (attachments.isNotEmpty) onPicked(attachments, AttachmentKind.image);
                },
              ),
              _Option(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final attachment = await _capturePhoto();
                  if (attachment != null) onPicked([attachment], AttachmentKind.image);
                },
              ),
              _Option(
                icon: Icons.insert_drive_file_outlined,
                label: 'Document',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final attachment = await _pickDocument();
                  if (attachment != null) onPicked([attachment], AttachmentKind.document);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  static Future<List<MessageAttachment>> _pickPhotos(BuildContext context) async {
    final assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
        requestType: RequestType.image,
        maxAssets: 9,
      ),
    );
    if (assets == null || assets.isEmpty) return [];

    final attachments = <MessageAttachment>[];
    for (final asset in assets) {
      final file = await asset.file;
      if (file == null) continue;
      attachments.add(
        MessageAttachment(
          id: asset.id,
          kind: AttachmentKind.image,
          fileName: await asset.titleAsync,
          localPath: file.path,
          fileSizeBytes: await file.length(),
          width: asset.width,
          height: asset.height,
        ),
      );
    }
    return attachments;
  }

  static Future<MessageAttachment?> _capturePhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return null;
    final length = await picked.length();
    return MessageAttachment(
      id: picked.path,
      kind: AttachmentKind.image,
      fileName: picked.name,
      localPath: picked.path,
      fileSizeBytes: length,
    );
  }

  static Future<MessageAttachment?> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    final file = result?.files.single;
    if (file == null || file.path == null) return null;
    return MessageAttachment(
      id: file.path!,
      kind: AttachmentKind.document,
      fileName: file.name,
      localPath: file.path,
      fileSizeBytes: file.size,
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkTeal),
      title: Text(label),
      onTap: onTap,
    );
  }
}
