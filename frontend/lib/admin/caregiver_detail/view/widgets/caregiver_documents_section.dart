import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_profile_model.dart';

/// "Uploaded Documents" section: horizontally scrolling preview cards.
class CaregiverDocumentsSection extends StatelessWidget {
  const CaregiverDocumentsSection({required this.documents, super.key});

  final List<CaregiverDocument> documents;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded Documents',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceLight,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: documents.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final doc = documents[index];
              return _DocumentCard(
                document: doc,
                onTap: () => _openPreview(context, doc),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openPreview(BuildContext context, CaregiverDocument doc) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _DocumentPreviewPage(document: doc),
        fullscreenDialog: true,
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document, this.onTap});

  final CaregiverDocument document;
  final VoidCallback? onTap;

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
    return Material(
      color: AppColors.surfaceContainerLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariantLight),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: Colors.white),
                    Center(
                      child: Icon(
                        _icon,
                        size: 40,
                        color: AppColors.outlineLight.withValues(alpha: 0.3),
                      ),
                    ),
                    Image.network(
                      document.previewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                color: AppColors.surfaceContainerHighLight,
                child: Row(
                  children: [
                    Icon(
                      _icon,
                      size: 18,
                      color: AppColors.onSurfaceVariantLight,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            document.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariantLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            document.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariantLight
                                  .withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal full-screen viewer, matching the pattern established in
/// `caregiver_review/view/widgets/document_preview_page.dart` — kept
/// as a local, lighter copy here rather than importing that file, to
/// keep this feature self-contained (same reasoning as the duplicated
/// bottom nav bars / status enums across other features in this app).
class _DocumentPreviewPage extends StatelessWidget {
  const _DocumentPreviewPage({required this.document});

  final CaregiverDocument document;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              document.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              document.subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.network(
            document.previewUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Text(
              'Unable to load this document.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }
}