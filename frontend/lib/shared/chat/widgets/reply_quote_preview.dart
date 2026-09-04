import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';

/// A small quoted-message card — used both above a bubble to show what it
/// is replying to, and above the composer to preview the message that's
/// about to be replied to (with a close button, via [onClose]).
class ReplyQuotePreview extends StatelessWidget {
  const ReplyQuotePreview({
    super.key,
    required this.senderName,
    required this.previewText,
    this.onClose,
  });

  final String senderName;
  final String previewText;

  /// Shown as a close button when set — used for the composer's "replying
  /// to..." banner, omitted for the read-only quote inside a bubble.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paleMint.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: AppColors.darkTeal, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTeal,
                  ),
                ),
                Text(
                  previewText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
