import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/theme/app_colors.dart';

import '../cubit/call_cubit.dart';
import '../models/call_session.dart';
import '../models/chat_participant.dart';
import '../widgets/call_controls_bar.dart';

/// Full-screen voice/video call UI. There is no signaling backend in this
/// app (see `call_session.dart`), so the "other side" answering is
/// simulated by [CallCubit] — but the local mic/camera are real: video
/// calls show a genuine self-view via the `camera` package (mobile only,
/// per project scope).
class CallScreen extends StatefulWidget {
  const CallScreen({
    super.key,
    required this.conversationId,
    required this.participants,
    required this.isVideo,
    this.groupTitle,
    this.isIncoming = false,
  });

  final String conversationId;

  /// Everyone else on the call. A single entry for a 1:1 call, or every
  /// other member of the group when [groupTitle] is set.
  final List<ChatParticipant> participants;
  final bool isVideo;
  final String? groupTitle;
  final bool isIncoming;

  bool get isGroupCall => groupTitle != null;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  CameraController? _cameraController;
  bool _cameraFailed = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraFailed = true);
        return;
      }
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(front, ResolutionPreset.medium, enableAudio: false);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _cameraController = controller);
    } catch (_) {
      if (mounted) setState(() => _cameraFailed = true);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CallCubit(
        conversationId: widget.conversationId,
        participants: widget.participants,
        groupTitle: widget.groupTitle,
        isVideo: widget.isVideo,
        isIncoming: widget.isIncoming,
      ),
      child: BlocConsumer<CallCubit, CallCubitState>(
        listener: (context, state) {
          if (state.session.state == CallState.ended) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) Navigator.of(context).maybePop();
            });
          }
        },
        builder: (context, state) {
          final cubit = context.read<CallCubit>();
          final session = state.session;

          return PopScope(
            canPop: session.state == CallState.ended,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) cubit.endCall();
            },
            child: Scaffold(
              backgroundColor: const Color(0xFF0B1F1C),
              body: SafeArea(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          widget.isGroupCall
                              ? _GroupCallAvatars(participants: widget.participants)
                              : _SoloCallAvatar(
                                  participant: widget.participants.isNotEmpty
                                      ? widget.participants.first
                                      : null,
                                ),
                          const SizedBox(height: 16),
                          Text(
                            session.displayName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.isGroupCall) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.participants.map((p) => p.name).join(', '),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, color: Colors.white54),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            _statusLabel(session, state.elapsedLabel),
                            style: const TextStyle(fontSize: 15, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isVideo && session.isCameraOn && _cameraController != null)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: 110,
                            height: 150,
                            child: CameraPreview(_cameraController!),
                          ),
                        ),
                      )
                    else if (widget.isVideo && _cameraFailed)
                      const Positioned(
                        top: 16,
                        right: 16,
                        child: _CameraUnavailableBadge(),
                      ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: widget.isIncoming && session.state == CallState.ringing
                            ? _IncomingCallActions(cubit: cubit)
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: CallControlsBar(
                                  isMuted: session.isMuted,
                                  isSpeakerOn: session.isSpeakerOn,
                                  isVideo: widget.isVideo,
                                  isCameraOn: session.isCameraOn,
                                  onToggleMute: cubit.toggleMute,
                                  onToggleSpeaker: cubit.toggleSpeaker,
                                  onToggleCamera: cubit.toggleCamera,
                                  onEndCall: cubit.endCall,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(CallSession session, String elapsedLabel) {
    switch (session.state) {
      case CallState.ringing:
        return widget.isIncoming
            ? '${widget.isVideo ? 'Video' : 'Voice'} call'
            : 'Calling…';
      case CallState.connecting:
        return 'Connecting…';
      case CallState.active:
        return elapsedLabel;
      case CallState.ended:
        return 'Call ended';
    }
  }
}

class _SoloCallAvatar extends StatelessWidget {
  const _SoloCallAvatar({required this.participant});

  final ChatParticipant? participant;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 56,
      backgroundColor: participant?.avatarColor ?? AppColors.paleMint,
      child: Text(
        participant?.initials ?? '?',
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.darkTeal),
      ),
    );
  }
}

/// Overlapping avatar cluster for a group call — shows up to 4 members
/// plus a "+N" badge for the rest.
class _GroupCallAvatars extends StatelessWidget {
  const _GroupCallAvatars({required this.participants});

  final List<ChatParticipant> participants;

  // Bubble diameter and how much each successive bubble overlaps the last.
  static const double _bubbleSize = 72;
  static const double _overlap = 20;
  static const double _step = _bubbleSize - _overlap;

  @override
  Widget build(BuildContext context) {
    const maxShown = 4;
    final shown = participants.take(maxShown).toList();
    final overflow = participants.length - shown.length;
    final bubbleCount = shown.length + (overflow > 0 ? 1 : 0);
    final totalWidth = bubbleCount == 0 ? 0.0 : _bubbleSize + (bubbleCount - 1) * _step;

    Widget bubble(Widget inner) => Container(
          width: _bubbleSize,
          height: _bubbleSize,
          decoration: const BoxDecoration(color: Color(0xFF0B1F1C), shape: BoxShape.circle),
          padding: const EdgeInsets.all(4),
          child: inner,
        );

    // Positioned (rather than negative Padding, which asserts non-negative
    // insets) so bubbles can overlap.
    return SizedBox(
      width: totalWidth,
      height: _bubbleSize,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * _step,
              child: bubble(
                CircleAvatar(
                  backgroundColor: shown[i].avatarColor,
                  child: Text(
                    shown[i].initials,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTeal,
                    ),
                  ),
                ),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: shown.length * _step,
              child: bubble(
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Text(
                    '+$overflow',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IncomingCallActions extends StatelessWidget {
  const _IncomingCallActions({required this.cubit});

  final CallCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CallControlButton(
            icon: Icons.call_end,
            backgroundColor: AppColors.warningRed,
            onTap: cubit.decline,
            label: 'Decline',
          ),
          CallControlButton(
            icon: Icons.call,
            backgroundColor: AppColors.primaryTeal,
            iconColor: AppColors.darkTeal,
            onTap: cubit.accept,
            label: 'Accept',
          ),
        ],
      ),
    );
  }
}

class _CameraUnavailableBadge extends StatelessWidget {
  const _CameraUnavailableBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.videocam_off, color: Colors.white70),
    );
  }
}
