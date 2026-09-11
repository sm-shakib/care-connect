import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../shared/chat/data/chat_socket_service.dart';
import '../../shared/sos/sos_alert_args.dart';
import '../../shared/sos/sos_alert_screen.dart';

/// Catches `sos:alert` pushes from anywhere in the app — the same way
/// `IncomingCallService` catches `call:invite` and `MedicineAlarmService`
/// catches a scheduled dose — all riding the single chat socket connection
/// that `ChatUnreadBadge` opens as soon as any dashboard shell mounts, for
/// whichever role (family or caregiver) is signed in. See
/// `backend/app/api/elder.py::trigger_sos` for the sender.
///
/// An SOS is an emergency, so on top of the OS notification (heard even if
/// the app is backgrounded or killed — alarm sound, `fullScreenIntent` and
/// all) this pushes the shared full-screen [SosAlertScreen] itself: right
/// away if the app is already open when the event arrives, or from the
/// notification tap/a cold start otherwise — exactly how
/// `MedicineAlarmService` pushes `MedicineAlarmPage`.
class SosAlertService {
  SosAlertService._();

  static final SosAlertService instance = SosAlertService._();

  static const _channelId = 'sos_alerts';
  static const _channelName = 'SOS alerts';
  static const _channelDescription =
      'Alerts family and caregivers when someone they care for presses SOS.';

  /// Filename (no extension) of the alarm tone, bundled as an Android raw
  /// resource at `android/app/src/main/res/raw/alarm_sound.<ext>` — the
  /// same tone `MedicineAlarmService` uses for medicine reminders, so an
  /// SOS is unmistakably an emergency rather than a routine notification.
  /// This only covers the notification's own one-shot sound; the looping
  /// playback while the alert is on screen is handled by [SosAlertScreen]
  /// with `audioplayers`, from the Flutter asset at
  /// `assets/sounds/alarm_sound.mp3`.
  static const _alarmSoundResource = 'alarm_sound';

  final _plugin = FlutterLocalNotificationsPlugin();
  GlobalKey<NavigatorState>? _navigatorKey;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  bool _initialized = false;

  /// Guards against pushing a second [SosAlertScreen] while one is already
  /// on screen — several people can be notified of the same SOS in quick
  /// succession, but a single viewer should still only be interrupted once.
  bool _isShowingAlert = false;

  /// Kept clear of `MedicineAlarmService`'s hash-based ids so the two
  /// never collide in the notification tray.
  int _nextNotificationId = 900000;

  /// Sets up the notification plugin, requests the necessary permissions,
  /// and wires notification taps (and events arriving while the app is
  /// open) to push [SosAlertScreen] via [navigatorKey]. Safe to call more
  /// than once.
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    if (_initialized) return;
    _initialized = true;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound(_alarmSoundResource),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
    await androidPlugin?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Cold start: the app was launched by tapping an SOS notification.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final payload = launchDetails?.notificationResponse?.payload;
    if ((launchDetails?.didNotificationLaunchApp ?? false) && payload != null) {
      _openAlertScreen(payload);
    }

    unawaited(_subscription?.cancel());
    _subscription = ChatSocketService.instance.events.listen(_handleEvent);
  }

  Future<void> _handleEvent(Map<String, dynamic> event) async {
    if (event['type'] != 'sos:alert') return;
    final raw = event['notification'];
    if (raw is! Map) return;
    final notification = Map<String, dynamic>.from(raw);

    final title = notification['title']?.toString() ?? '🚨 SOS Alert';
    final body = notification['body']?.toString() ?? '';
    final args = SosAlertArgs(
      elderName:
          notification['elder_name']?.toString() ?? 'Someone you care for',
      body: body,
      latitude: (notification['latitude'] as num?)?.toDouble(),
      longitude: (notification['longitude'] as num?)?.toDouble(),
    );

    final notificationId =
        900000 + ((notification['id'] as num?)?.toInt() ?? _nextNotificationId++);

    await _plugin.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          // Only takes effect below Android 8 (API 26) — from 8 onward the
          // channel's own sound (set in `initialize`) is what's used.
          sound: RawResourceAndroidNotificationSound(_alarmSoundResource),
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: args.encode(),
    );

    // The app may already be open somewhere — interrupt it immediately
    // rather than waiting for a notification tap that may never come.
    _openAlertScreenWithArgs(args);
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) _openAlertScreen(payload);
  }

  void _openAlertScreen(String payload) {
    try {
      _openAlertScreenWithArgs(SosAlertArgs.decode(payload));
    } catch (_) {
      // Malformed payload — nothing sensible to show.
    }
  }

  void _openAlertScreenWithArgs(SosAlertArgs args) {
    if (_isShowingAlert) return;
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;

    _isShowingAlert = true;
    navigator
        .push(MaterialPageRoute<void>(builder: (_) => SosAlertScreen(args: args)))
        .whenComplete(() => _isShowingAlert = false);
  }
}
