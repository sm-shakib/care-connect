import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/chat/data/chat_socket_service.dart';

/// Catches `sos:alert` pushes from anywhere in the app — the same way
/// `IncomingCallService` catches `call:invite` — both riding the single
/// chat socket connection that `ChatUnreadBadge` opens as soon as any
/// dashboard shell mounts, for whichever role (family or caregiver) is
/// signed in. See `backend/app/api/elder.py::trigger_sos` for the sender.
///
/// Unlike a call or a medicine alarm, reacting to an SOS never needs a
/// route inside this app — the payload is just a place on the map — so
/// both the notification's tap handler and a cold start from one just
/// launch the device's maps app directly, no `NavigatorState` needed.
class SosAlertService {
  SosAlertService._();

  static final SosAlertService instance = SosAlertService._();

  static const _channelId = 'sos_alerts';
  static const _channelName = 'SOS alerts';
  static const _channelDescription =
      'Alerts family and caregivers when someone they care for presses SOS.';

  final _plugin = FlutterLocalNotificationsPlugin();
  StreamSubscription<Map<String, dynamic>>? _subscription;
  bool _initialized = false;

  /// Kept clear of `MedicineAlarmService`'s hash-based ids so the two
  /// never collide in the notification tray.
  int _nextNotificationId = 900000;

  Future<void> initialize() async {
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
      unawaited(_openMap(payload));
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
    final payload = jsonEncode({
      'latitude': notification['latitude'],
      'longitude': notification['longitude'],
    });

    final notificationId =
        900000 + ((notification['id'] as num?)?.toInt() ?? _nextNotificationId++);

    await _plugin.show(
      notificationId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) unawaited(_openMap(payload));
  }

  /// Opens the device's maps app centered on the alert's coordinates — the
  /// same Google Maps deep link `LiveLocationCard` uses on the family tab.
  Future<void> _openMap(String payload) async {
    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      final latitude = decoded['latitude']?.toString();
      final longitude = decoded['longitude']?.toString();
      if (latitude == null || longitude == null) return;

      final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Malformed payload — nothing sensible to open.
    }
  }
}
