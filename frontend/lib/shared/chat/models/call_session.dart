import 'chat_participant.dart';

enum CallState { ringing, connecting, active, ended }

/// In-app model of an ongoing call, driven by `CallCubit` through a real
/// WebRTC connection (ringing -> connecting -> active), signaled over the
/// backend's `/ws/chat` WebSocket — see `CallCubit`'s doc comment for the
/// signaling protocol.
///
/// Works for both 1:1 calls (a single entry in [participants]) and group
/// calls (every other member of the group conversation) — [groupTitle] is
/// set only for the latter.
class CallSession {
  const CallSession({
    required this.conversationId,
    required this.participants,
    required this.isVideo,
    required this.isIncoming,
    this.groupTitle,
    this.state = CallState.ringing,
    this.startedAt,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.isCameraOn = true,
  });

  final String conversationId;

  /// Everyone on the call besides the current device user.
  final List<ChatParticipant> participants;

  /// The group's name, set only when this is a group call.
  final String? groupTitle;

  final bool isVideo;
  final bool isIncoming;
  final CallState state;
  final DateTime? startedAt;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isCameraOn;

  bool get isGroupCall => groupTitle != null;

  /// Name shown at the top of the call screen: the group's name for group
  /// calls, otherwise the other participant's name.
  String get displayName =>
      groupTitle ?? (participants.isNotEmpty ? participants.first.name : 'Unknown');

  CallSession copyWith({
    CallState? state,
    DateTime? startedAt,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isCameraOn,
  }) {
    return CallSession(
      conversationId: conversationId,
      participants: participants,
      groupTitle: groupTitle,
      isVideo: isVideo,
      isIncoming: isIncoming,
      state: state ?? this.state,
      startedAt: startedAt ?? this.startedAt,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isCameraOn: isCameraOn ?? this.isCameraOn,
    );
  }
}
