import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/medicine.dart';
import 'medicine_alarm_args.dart';
import 'medicine_alarm_page.dart';

/// Schedules and handles the elder-only "time to take your medicine" alarm.
///
/// This is only ever driven by [MedicineCubit], which is only constructed
/// for the elderly role — no other module schedules medicine alarms.
class MedicineAlarmService {
  MedicineAlarmService._();

  static final MedicineAlarmService instance = MedicineAlarmService._();

  static const snoozeDuration = Duration(minutes: 15);

  static const _channelId = 'medicine_alarms';
  static const _channelName = 'Medicine reminders';
  static const _channelDescription =
      'Alerts the elder when it is time to take a medicine.';

  /// Filename (no extension) of the alarm tone, bundled as an Android raw
  /// resource at `android/app/src/main/res/raw/alarm_sound.<ext>`. This only
  /// covers the notification's own one-shot sound; the looping playback
  /// while the alarm is on screen is handled by [MedicineAlarmPage] with
  /// `audioplayers`, from the Flutter asset at `assets/sounds/alarm_sound.mp3`.
  static const _alarmSoundResource = 'alarm_sound';

  final _plugin = FlutterLocalNotificationsPlugin();
  GlobalKey<NavigatorState>? _navigatorKey;
  bool _initialized = false;

  final _medicineUpdatedController = StreamController<void>.broadcast();

  /// Fires whenever a dose is marked taken from [MedicineAlarmPage] —
  /// which updates the backend directly and has no reference to whatever
  /// [MedicineCubit] instance is already alive elsewhere in the app.
  /// [MedicineCubit] listens to this to know when to reload, since a dose
  /// taken from the alarm screen would otherwise leave it showing stale
  /// data until something else happened to trigger a refresh.
  Stream<void> get onMedicineUpdated => _medicineUpdatedController.stream;

  /// Called by [MedicineAlarmPage] after successfully marking a dose taken.
  void notifyMedicineUpdated() => _medicineUpdatedController.add(null);

  /// Sets up the notification plugin, requests the necessary permissions,
  /// and wires notification taps to open [MedicineAlarmPage] via
  /// [navigatorKey]. Safe to call more than once.
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();
    try {
      final locationName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    } catch (e) {
      debugPrint('MedicineAlarmService: falling back to UTC timezone: $e');
    }

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
    await androidPlugin?.requestExactAlarmsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Cold start: the app was launched by tapping a medicine alarm.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final payload = launchDetails?.notificationResponse?.payload;
    if ((launchDetails?.didNotificationLaunchApp ?? false) && payload != null) {
      _openAlarmPage(payload);
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) _openAlarmPage(payload);
  }

  void _openAlarmPage(String payload) {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;
    final args = MedicineAlarmArgs.decode(payload);
    navigator.push(
      MaterialPageRoute<void>(builder: (_) => MedicineAlarmPage(args: args)),
    );
  }

  /// Deterministic notification id for a given medicine dose, so
  /// rescheduling the same dose replaces rather than duplicates it.
  int _doseNotificationId(String medicineId, String time) =>
      Object.hash(medicineId, time) & 0x7fffffff;

  /// Recomputes every scheduled alarm from scratch to match [medicines]:
  /// cancels everything, then schedules one recurring daily notification
  /// per dose time for medicines that haven't ended yet. Call this
  /// whenever the elder's medicine list changes.
  Future<void> syncSchedule(List<Medicine> medicines) async {
    if (!_initialized) return;
    await _plugin.cancelAll();

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    for (final medicine in medicines) {
      if (medicine.endDate.isBefore(startOfToday)) continue;

      for (final time in medicine.scheduleTimes) {
        final parsed = _parseTimeOfDay(time);
        if (parsed == null) continue;

        final args = MedicineAlarmArgs(
          medicineId: medicine.id,
          time: time,
          name: medicine.name,
          nameBn: medicine.nameBn,
          dosage: medicine.dosage,
          imagePath: medicine.imagePath,
        );

        await _plugin.zonedSchedule(
          _doseNotificationId(medicine.id, time),
          medicine.name,
          medicine.dosage,
          _nextInstanceOf(parsed),
          _notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: args.encode(),
        );
      }
    }
  }

  /// Cancels the alarm for one dose and re-fires it [snoozeDuration] later.
  Future<void> snooze(MedicineAlarmArgs args) async {
    if (!_initialized) return;
    await _plugin.zonedSchedule(
      _doseNotificationId(args.medicineId, '${args.time}#snooze'),
      args.name,
      args.dosage,
      tz.TZDateTime.now(tz.local).add(snoozeDuration),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: args.encode(),
    );
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
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
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Parses a pre-formatted time label like "8:00 AM", or `null` if it
  /// doesn't match that shape.
  TimeOfDay? _parseTimeOfDay(String label) {
    final match =
        RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$').firstMatch(label.trim());
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final meridiem = match.group(3)!.toUpperCase();
    if (meridiem == 'PM' && hour != 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
