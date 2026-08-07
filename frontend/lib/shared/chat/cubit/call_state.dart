part of 'call_cubit.dart';

class CallCubitState extends Equatable {
  const CallCubitState({required this.session, this.elapsedSeconds = 0});

  final CallSession session;
  final int elapsedSeconds;

  String get elapsedLabel {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  CallCubitState copyWith({CallSession? session, int? elapsedSeconds}) {
    return CallCubitState(
      session: session ?? this.session,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  @override
  List<Object?> get props => [session, elapsedSeconds];
}
