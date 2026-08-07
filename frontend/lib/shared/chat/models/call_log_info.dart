/// How a logged call ended, shown inline in the message thread as a
/// call-log entry (similar to WhatsApp/iMessage call bubbles).
enum CallOutcome { answered, missed, declined }

class CallLogInfo {
  const CallLogInfo({
    required this.isVideo,
    required this.outcome,
    required this.isOutgoing,
    this.duration = Duration.zero,
  });

  final bool isVideo;
  final CallOutcome outcome;
  final bool isOutgoing;
  final Duration duration;

  String get label {
    switch (outcome) {
      case CallOutcome.missed:
        return isOutgoing ? 'No answer' : 'Missed call';
      case CallOutcome.declined:
        return isOutgoing ? 'Call declined' : 'You declined';
      case CallOutcome.answered:
        final minutes = duration.inMinutes;
        final seconds = duration.inSeconds % 60;
        return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    }
  }
}
