import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';

import '../cubit/voice_recorder_controller.dart';
import '../models/chat_message.dart';
import '../models/message_attachment.dart';
import 'attachment_picker_sheet.dart';
import 'reply_quote_preview.dart';

/// The message composer: text field + attach button + mic button, adapted
/// from the old caregiver-only `ChatInputBar`. Tapping the mic starts a
/// voice recording (rather than requiring a press-and-hold gesture, which
/// is harder to use reliably for the app's elderly users — consistent
/// with the large-touch-target accessibility spec in `AppTheme`); tapping
/// it again sends the note, or it can be cancelled explicitly.
///
/// When [replyTarget] is set, a quoted preview banner shows above the
/// input with a close button ([onCancelReply]) — the next message sent
/// (of any kind) replies to it.
class ChatComposerBar extends StatefulWidget {
  const ChatComposerBar({
    super.key,
    required this.onSendText,
    required this.onSendAttachments,
    required this.onSendVoice,
    this.onTypingChanged,
    this.replyTarget,
    this.onCancelReply,
  });

  final ValueChanged<String> onSendText;
  final void Function(List<MessageAttachment> attachments, AttachmentKind kind)
  onSendAttachments;
  final ValueChanged<MessageAttachment> onSendVoice;

  /// Called with the current draft on every keystroke, so the peers can be
  /// shown a typing indicator. Whether that's worth sending — and how
  /// often — is the repository's call, not this widget's.
  final ValueChanged<String>? onTypingChanged;

  final ChatMessage? replyTarget;
  final VoidCallback? onCancelReply;

  @override
  State<ChatComposerBar> createState() => _ChatComposerBarState();
}

class _ChatComposerBarState extends State<ChatComposerBar> {
  final _controller = TextEditingController();
  final _recorder = VoiceRecorderController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final canSend = _controller.text.trim().isNotEmpty;
      if (canSend != _canSend) setState(() => _canSend = canSend);
      widget.onTypingChanged?.call(_controller.text);
    });
    _recorder.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _handleSendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    _controller.clear();
  }

  Future<void> _startRecording() async {
    final started = await _recorder.start();
    if (!started && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Microphone permission is needed to record voice messages.',
          ),
        ),
      );
    }
  }

  Future<void> _stopAndSendRecording() async {
    final attachment = await _recorder.stop();
    if (attachment != null) widget.onSendVoice(attachment);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final replyTarget = widget.replyTarget;

    if (_recorder.isRecording) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyTarget != null) _replyBanner(replyTarget),
          _RecordingBar(
            recorder: _recorder,
            onCancel: () => _recorder.cancel(),
            onSend: _stopAndSendRecording,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (replyTarget != null) _replyBanner(replyTarget),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: AppColors.darkTeal,
                  ),
                  onPressed: () => AttachmentPickerSheet.show(
                    context,
                    onPicked: widget.onSendAttachments,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSendText(),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      // fillColor: colorScheme.surfaceContainerLow,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkTeal,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _canSend ? Icons.send : Icons.mic,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _canSend ? _handleSendText : _startRecording,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _replyBanner(ChatMessage replyTarget) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      color: const Color(0xFFF1F5F9),
      child: ReplyQuotePreview(
        senderName: replyTarget.isFromMe ? 'You' : replyTarget.senderName,
        previewText: replyTarget.previewText,
        onClose: widget.onCancelReply,
      ),
    );
  }
}

class _RecordingBar extends StatelessWidget {
  const _RecordingBar({
    required this.recorder,
    required this.onCancel,
    required this.onSend,
  });

  final VoiceRecorderController recorder;
  final VoidCallback onCancel;
  final VoidCallback onSend;

  String get _elapsedLabel {
    final seconds = recorder.elapsed.inSeconds;
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        // color: colorScheme.surfaceContainerLow,
        color: const Color(0xFFF1F5F9),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: onCancel,
              tooltip: 'Cancel recording',
            ),
            const Icon(
              Icons.fiber_manual_record,
              color: AppColors.warningRed,
              size: 14,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Waveform(amplitude: recorder.amplitude),
            ),
            const SizedBox(width: 8),
            Text(
              _elapsedLabel,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.darkTeal,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.check, color: Colors.white, size: 20),
                onPressed: onSend,
                tooltip: 'Send voice message',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform({required this.amplitude});

  final double amplitude;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: List.generate(24, (i) {
          final wobble = (i.isEven ? amplitude : amplitude * 0.6).clamp(
            0.15,
            1.0,
          );
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              height: 24 * wobble,
              decoration: BoxDecoration(
                color: AppColors.darkTeal,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
