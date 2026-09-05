import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Makes a call audible. Until this existed, an incoming call pushed a
/// silent full-screen `CallScreen` and nothing else — no tone, no
/// vibration, nothing at all if the app happened to be in the background
/// — which is what "calls don't ring the recipient" meant in practice.
///
/// Two jobs, one owner, because they have to start and stop together:
///
/// - The **ringtone**, looped on the platform's ringtone audio stream
///   (not the media stream, so the phone's ring volume governs it). On
///   Android that is the phone's *own* ringtone — the one the user picked
///   in Settings — played natively by `MainActivity`, since Flutter's
///   audio plugins can only reach bundled assets. Every other platform,
///   and any device whose ringtone won't play, falls back to the bundled
///   `assets/sounds/call_ringtone.wav`. The caller hears that bundled
///   tone, quieter, as ringback — so it's obvious the call is going out
///   without it sounding like a call coming in.
/// - A **full-screen-intent notification** on Android, so a call still
///   reaches the user when the app is backgrounded and pushing a route
///   alone would show them nothing. The notification is deliberately
///   silent (`playSound: false`): the looping player above is the single
///   source of the sound, otherwise the two overlap out of phase.
///
/// [MedicineAlarmService] already called `initialize` on the notification
/// plugin — doing it twice would replace its tap handler and break
/// medicine alarms — so this only ever creates its own channel and shows.
/// Its payload is left null for the same reason: taps land in the
/// medicine service's handler, which ignores a null payload.
class CallRingService {
  CallRingService._();

  static final CallRingService instance = CallRingService._();

  static const _channelId = 'incoming_calls';
  static const _channelName = 'Incoming calls';
  static const _channelDescription =
      'Rings when someone starts a voice or video call with you.';

  /// Fixed id: only one call can be ringing at a time, so a second one
  /// replaces the first rather than stacking up notifications.
  static const _notificationId = 776601;

  /// Plays the ringtone configured on the device. See `MainActivity.kt`.
  static const _deviceRingtoneChannel = MethodChannel('care_connect/ringtone');

  /// Fallback for platforms without the native ringtone, and for a device
  /// whose own ringtone can't be played (silent ringtone, deleted media).
  static const _ringtoneAsset = 'sounds/call_ringtone.wav';

  /// Ringback for the caller. Quieter than the callee's ring — it's
  /// feedback that the call is going out, not a demand for attention.
  static const _outgoingVolume = 0.35;
  static const _incomingVolume = 1.0;

  final _player = AudioPlayer();
  final _plugin = FlutterLocalNotificationsPlugin();

  bool _channelCreated = false;
  bool _isRinging = false;

  /// Rings for an incoming call from [callerName] and raises the
  /// full-screen notification. Safe to call when already ringing.
  Future<void> startIncoming({
    required String callerName,
    required bool isVideo,
  }) async {
    await _startTone(_incomingVolume, useDeviceRingtone: true);
    await _showNotification(callerName: callerName, isVideo: isVideo);
  }

  /// Plays ringback while an outgoing call waits to be answered. No
  /// notification — the caller is looking at the call screen already.
  ///
  /// Deliberately the bundled tone rather than the phone's ringtone: a
  /// ringback says "the other phone is ringing", and hearing your *own*
  /// ringtone when you place a call reads as an incoming one.
  Future<void> startOutgoing() =>
      _startTone(_outgoingVolume, useDeviceRingtone: false);

  /// Silences everything. Idempotent, and safe to call from teardown
  /// paths that may run more than once. Both tone sources are stopped
  /// without asking which one started, so a half-failed start can never
  /// leave a phone ringing.
  Future<void> stop() async {
    _isRinging = false;
    await _stopDeviceRingtone();
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('CallRingService: could not stop the ringtone: $e');
    }
    try {
      await _plugin.cancel(_notificationId);
    } catch (e) {
      debugPrint('CallRingService: could not clear the call notification: $e');
    }
  }

  Future<void> _startTone(
    double volume, {
    required bool useDeviceRingtone,
  }) async {
    if (_isRinging) return;
    _isRinging = true;
    if (useDeviceRingtone && await _startDeviceRingtone(volume)) return;
    await _startBundledTone(volume);
  }

  /// Rings with the phone's own ringtone. Returns whether it actually
  /// played, so the bundled tone can cover every case where it didn't.
  Future<bool> _startDeviceRingtone(double volume) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final started = await _deviceRingtoneChannel.invokeMethod<bool>('start', {
        'volume': volume,
      });
      return started ?? false;
    } catch (e) {
      debugPrint('CallRingService: could not play the device ringtone: $e');
      return false;
    }
  }

  Future<void> _stopDeviceRingtone() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _deviceRingtoneChannel.invokeMethod<void>('stop');
    } catch (e) {
      debugPrint('CallRingService: could not stop the device ringtone: $e');
    }
  }

  Future<void> _startBundledTone(double volume) async {
    try {
      await _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            // `notificationRingtone` is what puts this on the phone's ring
            // stream, so the ring volume (not the media volume) governs it
            // and it still sounds while music is playing.
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.notificationRingtone,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(volume);
      await _player.play(AssetSource(_ringtoneAsset));
    } catch (e) {
      // A missing audio route or a denied focus request must never take
      // the call itself down — the call screen is still usable silently.
      debugPrint('CallRingService: could not play the ringtone: $e');
    }
  }

  Future<void> _showNotification({
    required String callerName,
    required bool isVideo,
  }) async {
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin == null) return;

      if (!_channelCreated) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.max,
            playSound: false,
          ),
        );
        await androidPlugin.requestNotificationsPermission();
        _channelCreated = true;
      }

      await _plugin.show(
        _notificationId,
        isVideo ? 'Incoming video call' : 'Incoming call',
        callerName,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.call,
            // Wakes the screen and shows the call full-screen even from a
            // backgrounded app — the whole point of this notification.
            fullScreenIntent: true,
            // A ringing call isn't dismissible clutter; it goes away when
            // the call is answered, declined, or gives up.
            ongoing: true,
            autoCancel: false,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 900, 700, 900]),
            playSound: false,
          ),
        ),
      );
    } catch (e) {
      debugPrint('CallRingService: could not post the call notification: $e');
    }
  }
}
