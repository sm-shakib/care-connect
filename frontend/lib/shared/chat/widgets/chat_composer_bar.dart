import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';

import '../cubit/voice_recorder_controller.dart';
import '../models/message_attachment.dart';
import 'attachment_picker_sheet.dart';

/// The message composer: text field + attach button + mic button, adapted
/// from the old caregiver-only `ChatInputBar`. Tapping the mic starts a
/// voice recording (rather than requiring a press-and-hold gesture, which
/// is harder to use reliably for the app's elderly users — consistent
/// with the large-touch-target accessibility spec in `AppTheme`); tapping
/// it again sends the note, or it can be cancelled explicitly.
class ChatComposerBar extends StatefulWidget {
  const ChatComposerBar({
    super.key,
    required this.onSendText,
    required this.onSendAttachments,
    required this.onSendVoice,
  });

  final ValueChanged<String> onSendText;
  final void Function(List<MessageAttachment> attachments, AttachmentKind kind) onSendAttachments;
  final ValueChanged<MessageAttachment> onSendVoice;

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
        const SnackBar(content: Text('Microphone permission is needed to record voice messages.')),
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

    if (_recorder.isRecording) {
      return _RecordingBar(
        recorder: _recorder,
        onCancel: () => _recorder.cancel(),
        onSend: _stopAndSendRecording,
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: AppColors.darkTeal),
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
                  fillColor: colorScheme.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                icon: Icon(_canSend ? Icons.send : Icons.mic, color: Colors.white, size: 20),
                onPressed: _canSend ? _handleSendText : _startRecording,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingBar extends StatelessWidget {
  const _RecordingBar({required this.recorder, required this.onCancel, required this.onSend});

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
        color: colorScheme.surfaceContainerLow,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: onCancel,
              tooltip: 'Cancel recording',
            ),
            const Icon(Icons.fiber_manual_record, color: AppColors.warningRed, size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: _Waveform(amplitude: recorder.amplitude),
            ),
            const SizedBox(width: 8),
            Text(
              _elapsedLabel,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(color: AppColors.darkTeal, shape: BoxShape.circle),
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
          final wobble = (i.isEven ? amplitude : amplitude * 0.6).clamp(0.15, 1.0);
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
