import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
import 'package:flutter/material.dart';

import '../models/message_attachment.dart';

/// Voice message bubble — plays back the recorded/dummy audio file with
/// [chat_bubbles]' `BubbleNormalAudio` (play/pause, seek, waveform).
class VoiceMessageBubble extends StatefulWidget {
  const VoiceMessageBubble({
    super.key,
    required this.attachment,
    required this.isSender,
    required this.color,
    required this.textColor,
    this.timestamp,
    this.deliveryTicks,
  });

  final MessageAttachment attachment;
  final bool isSender;
  final Color color;
  final Color textColor;
  final String? timestamp;

  /// 0 = sent, 1 = delivered, 2 = read/seen — null hides ticks.
  final int? deliveryTicks;

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _duration = widget.attachment.duration ?? Duration.zero;
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
    });
  }

  Future<void> _togglePlayback() async {
    final source = widget.attachment.resolvedSource;
    if (source == null) return;

    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _player.play(DeviceFileSource(source));
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BubbleNormalAudio(
      isSender: widget.isSender,
      color: widget.color,
      isPlaying: _isPlaying,
      isLoading: _isLoading,
      duration: _duration.inMilliseconds / 1000,
      position: _position.inMilliseconds / 1000,
      onPlayPauseButtonClick: _togglePlayback,
      onSeekChanged: (seconds) => _player.seek(Duration(milliseconds: (seconds * 1000).round())),
      textStyle: TextStyle(color: widget.textColor, fontSize: 12),
      waveformData: _waveform,
      waveformActiveColor: widget.textColor,
      waveformInactiveColor: widget.textColor.withValues(alpha: 0.35),
      sent: widget.deliveryTicks != null && widget.deliveryTicks! >= 0,
      delivered: widget.deliveryTicks != null && widget.deliveryTicks! >= 1,
      seen: widget.deliveryTicks != null && widget.deliveryTicks! >= 2,
      timestamp: widget.timestamp,
    );
  }

  // Deterministic pseudo-waveform (no real decoded amplitude data is
  // available for dummy/mock audio) so the bubble still looks alive.
  static const _waveform = [
    0.3, 0.6, 0.9, 0.5, 0.7, 0.4, 0.8, 0.6, 0.3, 0.5,
    0.9, 0.6, 0.4, 0.7, 0.5, 0.8, 0.3, 0.6, 0.4, 0.5,
  ];
}
