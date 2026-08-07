import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';

/// Round icon button used on the call screen (mute/speaker/camera/end).
class CallControlButton extends StatelessWidget {
  const CallControlButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.backgroundColor,
    this.iconColor = Colors.white,
    this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final Color? backgroundColor;
  final Color iconColor;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ??
        (isActive ? Colors.white : Colors.white.withValues(alpha: 0.18));
    final fg = backgroundColor != null
        ? iconColor
        : (isActive ? AppColors.darkTeal : Colors.white);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: bg,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(icon, color: fg, size: 26),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(label!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ],
    );
  }
}

/// Row of mute/speaker/camera-toggle/end-call controls shown at the
/// bottom of [CallScreen].
class CallControlsBar extends StatelessWidget {
  const CallControlsBar({
    super.key,
    required this.isMuted,
    required this.isSpeakerOn,
    required this.isVideo,
    required this.isCameraOn,
    required this.onToggleMute,
    required this.onToggleSpeaker,
    required this.onToggleCamera,
    required this.onEndCall,
  });

  final bool isMuted;
  final bool isSpeakerOn;
  final bool isVideo;
  final bool isCameraOn;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleCamera;
  final VoidCallback onEndCall;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CallControlButton(
          icon: isMuted ? Icons.mic_off : Icons.mic,
          isActive: isMuted,
          onTap: onToggleMute,
          label: 'Mute',
        ),
        CallControlButton(
          icon: isSpeakerOn ? Icons.volume_up : Icons.hearing,
          isActive: isSpeakerOn,
          onTap: onToggleSpeaker,
          label: 'Speaker',
        ),
        if (isVideo)
          CallControlButton(
            icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
            isActive: !isCameraOn,
            onTap: onToggleCamera,
            label: 'Camera',
          ),
        CallControlButton(
          icon: Icons.call_end,
          backgroundColor: AppColors.warningRed,
          onTap: onEndCall,
          label: 'End',
        ),
      ],
    );
  }
}
