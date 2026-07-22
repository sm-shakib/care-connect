import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/theme/app_colors.dart';


class DocumentUploadTile extends StatelessWidget {
  const DocumentUploadTile({
    super.key,
    required this.documentTypeLabel,
    required this.onFilePicked,
    this.fileName,
    this.isRequired = true,
  });

  final String documentTypeLabel;
  final String? fileName;
  final bool isRequired;
  final ValueChanged<PlatformFile> onFilePicked;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = result?.files.single;
    if (file != null) {
      onFilePicked(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isUploaded = fileName != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUploaded
            ? AppColors.paleMint.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUploaded ? AppColors.darkTeal : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.upload_file_outlined,
            color: AppColors.darkTeal,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        documentTypeLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkTeal,
                        ),
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 4),
                      Text(
                        '*',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  fileName ?? l10n.noFileSelected,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _pickFile,
            style: TextButton.styleFrom(foregroundColor: AppColors.darkTeal),
            child: Text(isUploaded ? l10n.replaceLabel : l10n.uploadLabel),
          ),
        ],
      ),
    );
  }
}