part of 'call_cubit.dart';

class CallCubitState extends Equatable {
  const CallCubitState({
    required this.session,
    this.elapsedSeconds = 0,
    this.hasRemoteVideo = false,
  });

  final CallSession session;
  final int elapsedSeconds;

  /// True once at least one remote participant's video track has arrived
  /// — only ever set for 1:1 calls (see `CallCubit`'s doc comment on
  /// group-call scope).
  final bool hasRemoteVideo;

  String get elapsedLabel {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  CallCubitState copyWith({
    CallSession? session,
    int? elapsedSeconds,
    bool? hasRemoteVideo,
  }) {
    return CallCubitState(
      session: session ?? this.session,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      hasRemoteVideo: hasRemoteVideo ?? this.hasRemoteVideo,
    );
  }

  @override
  List<Object?> get props => [session, elapsedSeconds, hasRemoteVideo];
}
