import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_colors.dart';
import 'sos_alert_args.dart';

/// Full-screen "someone you care for needs help" alert, shown to family
/// and caregivers. Pushed by `SosAlertService` the moment an `sos:alert`
/// event arrives while the app is open, or from a notification tap/cold
/// start otherwise — mirroring how `MedicineAlarmService` pushes
/// `MedicineAlarmPage`. Deliberately self-contained: it renders from
/// [args] alone, since it can be the very first screen shown after a cold
/// start.
///
/// Unlike the medicine alarm, leaving this screen isn't gated behind an
/// action the elder is waiting on — the viewer can dismiss it once they've
/// seen it — but it still loops the same alarm tone for as long as it's on
/// screen, so an emergency can't be missed as just another notification
/// banner.
class SosAlertScreen extends StatefulWidget {
  const SosAlertScreen({required this.args, super.key});

  final SosAlertArgs args;

  @override
  State<SosAlertScreen> createState() => _SosAlertScreenState();
}

class _SosAlertScreenState extends State<SosAlertScreen>
    with SingleTickerProviderStateMixin {
  final _alarmSound = AudioPlayer();
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    unawaited(_playAlarmSound());
  }

  /// Loops the alarm tone for as long as this screen is on screen, routed
  /// through the alarm stream so it isn't silenced by a muted ringer —
  /// matching how the notification itself is configured in
  /// `SosAlertService`, and identical to how `MedicineAlarmPage` plays its
  /// tone. This is what actually guarantees the loop: a notification's own
  /// sound only ever plays once.
  Future<void> _playAlarmSound() async {
    try {
      await _alarmSound.setReleaseMode(ReleaseMode.loop);
      await _alarmSound.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
          iOS: AudioContextIOS(
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );
      await _alarmSound.play(AssetSource('sounds/alarm_sound.mp3'));
    } catch (e) {
      debugPrint('SosAlertScreen: failed to play alarm sound: $e');
    }
  }

  Future<void> _dismiss() async {
    unawaited(_alarmSound.stop());
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _openMap() async {
    final args = widget.args;
    if (!args.hasLocation) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${args.latitude},${args.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    unawaited(_alarmSound.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) unawaited(_alarmSound.stop());
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: _dismiss,
                  ),
                ),
                const Spacer(),
                _PulsingSosIcon(controller: _pulseController),
                const SizedBox(height: 40),
                const Text(
                  'SOS ALERT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${args.elderName} needs help',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (args.body != null && args.body!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    args.body!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
                const Spacer(),
                if (args.hasLocation) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.darkTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _openMap,
                      icon: const Icon(Icons.location_on, size: 20),
                      label: const Text(
                        'View on Map',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _dismiss,
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A siren-style pulsing icon: expanding, fading rings behind a solid
/// circle — the same treatment `SosAlertPage` uses on the elder's side
/// while sharing their location, reused here so an SOS reads the same way
/// on both ends of the alert.
class _PulsingSosIcon extends StatelessWidget {
  const _PulsingSosIcon({required this.controller});

  final AnimationController controller;

  static const _ringCount = 3;
  static const _maxDiameter = 220.0;
  static const _coreDiameter = 140.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _maxDiameter,
      height: _maxDiameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: List.generate(_ringCount, (i) {
                  final t = (controller.value + i / _ringCount) % 1.0;
                  final diameter =
                      _coreDiameter + (_maxDiameter - _coreDiameter) * t;
                  return Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0) * 0.55,
                    child: Container(
                      width: diameter,
                      height: diameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.warningRed, width: 2.5),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          Container(
            width: _coreDiameter,
            height: _coreDiameter,
            decoration: BoxDecoration(
              color: AppColors.warningRed,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.warningRed.withValues(alpha: 0.55),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.sos_rounded, color: Colors.white, size: 64),
          ),
        ],
      ),
    );
  }
}
