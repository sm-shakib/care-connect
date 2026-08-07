import 'dart:io';

import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';

import '../data/chat_repository.dart';
import '../models/message_attachment.dart';
import '../widgets/attachment_document_tile.dart';
import '../widgets/voice_message_bubble.dart';

/// Everything previously sent/received in a conversation, grouped into
/// Media / Files / Voice tabs — backs the "store previously sent media
/// and attachments" requirement.
class MediaGalleryPage extends StatelessWidget {
  const MediaGalleryPage({super.key, required this.repository, required this.conversationId});

  final ChatRepository repository;
  final String conversationId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Media & files'),
          bottom: const TabBar(
            labelColor: AppColors.darkTeal,
            indicatorColor: AppColors.darkTeal,
            tabs: [
              Tab(text: 'Media'),
              Tab(text: 'Files'),
              Tab(text: 'Voice'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MediaGrid(attachments: repository.mediaFor(conversationId, kind: AttachmentKind.image)),
            _FileList(attachments: repository.mediaFor(conversationId, kind: AttachmentKind.document)),
            _VoiceList(attachments: repository.mediaFor(conversationId, kind: AttachmentKind.voice)),
          ],
        ),
      ),
    );
  }
}

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({required this.attachments});

  final List<MessageAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const _EmptyState(label: 'No photos yet.');

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: attachments.length,
      itemBuilder: (context, index) {
        final source = attachments[index].resolvedSource;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: source == null
              ? Container(color: Theme.of(context).colorScheme.surfaceContainerLow)
              : source.startsWith('http')
                  ? Image.network(source, fit: BoxFit.cover)
                  : Image.file(File(source), fit: BoxFit.cover),
        );
      },
    );
  }
}

class _FileList extends StatelessWidget {
  const _FileList({required this.attachments});

  final List<MessageAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const _EmptyState(label: 'No documents yet.');

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: attachments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final attachment = attachments[index];
        return AttachmentDocumentTile(
          attachment: attachment,
          isSender: false,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          textColor: Theme.of(context).colorScheme.onSurface,
        );
      },
    );
  }
}

class _VoiceList extends StatelessWidget {
  const _VoiceList({required this.attachments});

  final List<MessageAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const _EmptyState(label: 'No voice messages yet.');

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: attachments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final attachment = attachments[index];
        return VoiceMessageBubble(
          attachment: attachment,
          isSender: false,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          textColor: Theme.of(context).colorScheme.onSurface,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
    );
  }
}
