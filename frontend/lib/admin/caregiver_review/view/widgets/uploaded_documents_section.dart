import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_application_model.dart';

/// "Uploaded Documents" section: header with a "View All" action, then a
/// horizontally scrolling row of document preview cards.
class UploadedDocumentsSection extends StatelessWidget {
  const UploadedDocumentsSection({
    required this.documents,
    this.onViewAll,
    this.onPreview,
    this.onExpand,
    this.onToggle,
    super.key,
  });

  final List<UploadedDocument> documents;
  final VoidCallback? onViewAll;
  final ValueChanged<UploadedDocument>? onPreview;
  final ValueChanged<UploadedDocument>? onExpand;
  final ValueChanged<UploadedDocument>? onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploaded Documents',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 264,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: documents.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final doc = documents[index];
              return _DocumentCard(
                document: doc,
                onPreview: () => onPreview?.call(doc),
                onExpand: () => onExpand?.call(doc),
                onToggle: () => onToggle?.call(doc),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.document,
    this.onPreview,
    this.onExpand,
    this.onToggle,
  });

  final UploadedDocument document;
  final VoidCallback? onPreview;
  final VoidCallback? onExpand;
  final VoidCallback? onToggle;

  IconData get _icon {
    switch (document.iconName) {
      case 'badge':
        return Icons.badge;
      case 'description':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariantLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 128,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.surfaceContainerHighLight),
                Center(
                  child: Icon(
                    _icon,
                    size: 56,
                    color: AppColors.outlineLight.withValues(alpha: 0.2),
                  ),
                ),
                Image.network(
                  document.previewUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filled(
                    onPressed: onToggle,
                    style: IconButton.styleFrom(
                      backgroundColor: document.isVerified
                          ? AppColors.primaryLight
                          : Colors.white,
                      foregroundColor: document.isVerified
                          ? Colors.white
                          : AppColors.onSurfaceVariantLight,
                    ),
                    icon: Icon(
                      document.isVerified ? Icons.check_circle : Icons.close,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  document.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  document.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariantLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onPreview,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide(color: AppColors.primaryLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: AppColors.primaryLight,
                        ),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text(
                          'Preview',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: onExpand,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(40, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide(
                            color: AppColors.outlineVariantLight,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: AppColors.onSurfaceVariantLight,
                        ),
                        child: const Icon(Icons.open_in_full, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
