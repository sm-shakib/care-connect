import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../models/message_attachment.dart';

/// Wraps the `record` package to capture voice messages for the chat
/// composer: start/stop/cancel, a live elapsed timer, and a normalized
/// (0..1) amplitude stream the composer animates into a waveform.
class VoiceRecorderController extends ChangeNotifier {
  VoiceRecorderController() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Timer? _ticker;
  String? _path;

  bool isRecording = false;
  Duration elapsed = Duration.zero;
  double amplitude = 0;

  Future<bool> start() async {
    if (isRecording) return true;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return false;

    final dir = await getTemporaryDirectory();
    _path = '${dir.path}/voice-${const Uuid().v4()}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _path!,
    );

    isRecording = true;
    elapsed = Duration.zero;
    amplitude = 0;
    notifyListeners();

    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      elapsed += const Duration(milliseconds: 200);
      notifyListeners();
    });

    _amplitudeSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 200))
        .listen((amp) {
      // Amplitude is reported in dB (roughly -45..0 for typical speech).
      amplitude = ((amp.current + 45) / 45).clamp(0, 1);
      notifyListeners();
    });

    return true;
  }

  /// Stops recording and returns the captured voice note, or null if the
  /// recording was too short to be worth sending.
  Future<MessageAttachment?> stop() async {
    if (!isRecording) return null;
    final duration = elapsed;
    final path = await _finish();
    if (path == null || duration < const Duration(milliseconds: 600)) {
      return null;
    }
    return MessageAttachment(
      id: const Uuid().v4(),
      kind: AttachmentKind.voice,
      fileName: 'voice-message.m4a',
      localPath: path,
      duration: duration,
      mimeType: 'audio/m4a',
    );
  }

  Future<void> cancel() async {
    await _finish();
  }

  Future<String?> _finish() async {
    _ticker?.cancel();
    _ticker = null;
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    final path = await _recorder.stop();
    isRecording = false;
    amplitude = 0;
    notifyListeners();
    return path;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _amplitudeSub?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}
