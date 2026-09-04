import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend/theme/app_colors.dart';

import '../models/call_log_info.dart';
import '../models/chat_message.dart';
import 'attachment_document_tile.dart';
import 'image_attachment_tile.dart';
import 'reply_quote_preview.dart';
import 'voice_message_bubble.dart';

/// Renders one [ChatMessage] as a themed bubble. Text bubbles use
/// `chat_bubbles`' `BubbleSpecialThree` directly; photo/voice bubbles
/// delegate to [ImageAttachmentTile]/[VoiceMessageBubble] (also
/// `chat_bubbles`-backed); documents and call-log entries use small
/// custom tiles styled to match the same bubble language, since the
/// package doesn't cover those content types.
///
/// Bubble color always follows the app theme: sent messages use
/// [AppColors.darkTeal] (matching the old caregiver-only chat bubble and
/// the app's primary brand color), received messages use the current
/// [ColorScheme]'s surface container — so this reads correctly in both
/// light and dark mode.
///
/// Long-pressing shows a Reply/Unsend menu (unsend only for the current
/// user's own, not-yet-deleted, non-call-log messages) when either
/// [onReply] or [onUnsend] is provided.
class ThemedChatBubble extends StatelessWidget {
  const ThemedChatBubble({
    super.key,
    required this.message,
    this.showSenderName = false,
    this.highlighted = false,
    this.onReply,
    this.onUnsend,
  });

  final ChatMessage message;
  final bool showSenderName;
  final bool highlighted;
  final VoidCallback? onReply;
  final VoidCallback? onUnsend;

  Future<void> _showActions(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFFBFEFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onReply != null)
              ListTile(
                leading: const Icon(Icons.reply, color: AppColors.darkTeal),
                title: const Text('Reply'),
                onTap: () => Navigator.pop(sheetContext, 'reply'),
              ),
            if (onUnsend != null)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: AppColors.warningRed,
                ),
                title: const Text('Unsend'),
                onTap: () => Navigator.pop(sheetContext, 'unsend'),
              ),
          ],
        ),
      ),
    );
    switch (action) {
      case 'reply':
        onReply?.call();
      case 'unsend':
        onUnsend?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSender = message.isFromMe;
    // final bubbleColor = isSender ? AppColors.darkTeal : const Color(0xFFFBFEFC);
    final bubbleColor = isSender ? AppColors.darkTeal : const Color(0xFFF1F5F9);
    final textColor = isSender ? Colors.white : colorScheme.onSurface;
    final timeLabel = DateFormat('h:mm a').format(message.timestamp);

    int? ticks;
    if (isSender) {
      ticks = switch (message.status) {
        MessageDeliveryStatus.sending => null,
        MessageDeliveryStatus.sent => 0,
        MessageDeliveryStatus.delivered => 1,
        MessageDeliveryStatus.read => 2,
        MessageDeliveryStatus.failed => null,
      };
    }

    Widget bubble = message.isDeleted
        ? _UnsentBubble(isSender: isSender, timeLabel: timeLabel)
        : switch (message.type) {
            ChatMessageType.text => BubbleSpecialThree(
              text: message.text ?? '',
              isSender: isSender,
              color: bubbleColor,
              textStyle: TextStyle(color: textColor, fontSize: 15),
              timestamp: timeLabel,
              sent: ticks != null && ticks >= 0,
              delivered: ticks != null && ticks >= 1,
              seen: ticks != null && ticks >= 2,
            ),
            ChatMessageType.image when message.primaryAttachment != null =>
              ImageAttachmentTile(
                attachment: message.primaryAttachment!,
                isSender: isSender,
                color: bubbleColor,
                timestamp: timeLabel,
                deliveryTicks: ticks,
              ),
            ChatMessageType.voice when message.primaryAttachment != null =>
              Align(
                alignment: isSender
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: VoiceMessageBubble(
                  attachment: message.primaryAttachment!,
                  isSender: isSender,
                  color: bubbleColor,
                  textColor: textColor,
                  timestamp: timeLabel,
                  deliveryTicks: ticks,
                ),
              ),
            ChatMessageType.document when message.primaryAttachment != null =>
              AttachmentDocumentTile(
                attachment: message.primaryAttachment!,
                isSender: isSender,
                color: bubbleColor,
                textColor: textColor,
              ),
            ChatMessageType.callLog => _CallLogBubble(
              message: message,
              isSender: isSender,
              color: bubbleColor,
              textColor: textColor,
              timeLabel: timeLabel,
            ),
            _ => const SizedBox.shrink(),
          };

    final replyTo = message.replyTo;
    if (replyTo != null && !message.isDeleted) {
      bubble = Column(
        crossAxisAlignment: isSender
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ReplyQuotePreview(
              senderName: replyTo.senderName,
              previewText: replyTo.preview,
            ),
          ),
          const SizedBox(height: 2),
          bubble,
        ],
      );
    }

    if (highlighted) {
      bubble = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: bubble,
      );
    }

    if (onReply != null || onUnsend != null) {
      bubble = GestureDetector(
        onLongPress: () => _showActions(context),
        child: bubble,
      );
    }

    if (!showSenderName || isSender) return bubble;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              message.senderName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          bubble,
        ],
      ),
    );
  }
}

class _UnsentBubble extends StatelessWidget {
  const _UnsentBubble({required this.isSender, required this.timeLabel});

  final bool isSender;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block,
                size: 16,
                color: Colors.black.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 6),
              Text(
                'This message was unsent',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeLabel,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.35),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallLogBubble extends StatelessWidget {
  const _CallLogBubble({
    required this.message,
    required this.isSender,
    required this.color,
    required this.textColor,
    required this.timeLabel,
  });

  final ChatMessage message;
  final bool isSender;
  final Color color;
  final Color textColor;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final log = message.callLog!;
    final icon = log.isVideo ? Icons.videocam : Icons.call;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: log.outcome == CallOutcome.missed
                    ? AppColors.warningRed
                    : textColor,
              ),
              const SizedBox(width: 8),
              Text(
                log.label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeLabel,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
