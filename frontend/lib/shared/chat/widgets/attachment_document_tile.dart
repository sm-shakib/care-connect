import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/message_attachment.dart';

/// Document bubble content. `chat_bubbles` has no document-bubble widget,
/// so this is a custom tile that intentionally mirrors the corner-radius
/// and color language of [ImageAttachmentTile]/[VoiceMessageBubble] so all
/// message types read as one consistent bubble family.
class AttachmentDocumentTile extends StatelessWidget {
  const AttachmentDocumentTile({
    super.key,
    required this.attachment,
    required this.isSender,
    required this.color,
    required this.textColor,
  });

  final MessageAttachment attachment;
  final bool isSender;
  final Color color;
  final Color textColor;

  Future<void> _open(BuildContext context) async {
    final source = attachment.resolvedSource;
    if (source == null) return;
    final uri = source.startsWith('http') ? Uri.parse(source) : Uri.file(source);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open this file on this device.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          child: Material(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isSender ? 16 : 4),
              bottomRight: Radius.circular(isSender ? 4 : 16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _open(context),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        attachment.fileExtension.isEmpty ? 'FILE' : attachment.fileExtension,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            attachment.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          if (attachment.formattedSize.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              attachment.formattedSize,
                              style: TextStyle(
                                fontSize: 11,
                                color: textColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
