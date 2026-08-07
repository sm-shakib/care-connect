import 'dart:io';

import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:flutter/material.dart';

import '../models/message_attachment.dart';

/// Photo bubble — [chat_bubbles]' `BubbleNormalImage`, which already
/// handles the rounded/tailed bubble shape and a tap-to-fullscreen Hero
/// transition.
class ImageAttachmentTile extends StatelessWidget {
  const ImageAttachmentTile({
    super.key,
    required this.attachment,
    required this.isSender,
    required this.color,
    this.timestamp,
    this.deliveryTicks,
  });

  final MessageAttachment attachment;
  final bool isSender;
  final Color color;
  final String? timestamp;
  final int? deliveryTicks;

  @override
  Widget build(BuildContext context) {
    final source = attachment.resolvedSource;
    final Widget image;
    if (source == null) {
      image = const Icon(Icons.broken_image_outlined, size: 48);
    } else if (source.startsWith('http')) {
      image = Image.network(source, fit: BoxFit.cover);
    } else {
      image = Image.file(File(source), fit: BoxFit.cover);
    }

    return BubbleNormalImage(
      id: attachment.id,
      image: image,
      isSender: isSender,
      color: color,
      sent: deliveryTicks != null && deliveryTicks! >= 0,
      delivered: deliveryTicks != null && deliveryTicks! >= 1,
      seen: deliveryTicks != null && deliveryTicks! >= 2,
      timestamp: timestamp,
    );
  }
}
