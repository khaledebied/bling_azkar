import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/models/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    bool androidGranted = true;
    bool iosGranted = true;

    if (androidImplementation != null) {
      androidGranted = await androidImplementation.requestNotificationsPermission() ?? false;
    }

    if (iosImplementation != null) {
      iosGranted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ?? false;
    }

    return androidGranted && iosGranted;
  }

  Future<void> scheduleReminder(
    Reminder reminder,
    String zikrTitle,
    String zikrText,
  ) async {
    await _notifications.cancel(reminder.notificationId ?? 0);

    final DateTime scheduledTime = _calculateNextScheduledTime(reminder);

    final androidDetails = AndroidNotificationDetails(
      'azkar_reminders',
      'Azkar Reminders',
      channelDescription: 'Local reminders for daily Azkar',
      importance: Importance.high,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('short_zikr_1'),
      enableVibration: true,
      playSound: true,
      ongoing: reminder.type == ReminderType.interval,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails(
      sound: 'short_zikr_1.aiff',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (reminder.type == ReminderType.fixedDaily) {
      // Schedule daily repeating notification
      await _notifications.zonedSchedule(
        reminder.notificationId ?? 0,
        zikrTitle,
        zikrText.length > 100 ? '${zikrText.substring(0, 100)}...' : zikrText,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.zikrId,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else {
      // Schedule one-time notification for interval reminders
      // The reminder service will reschedule after each notification
      await _notifications.zonedSchedule(
        reminder.notificationId ?? 0,
        zikrTitle,
        zikrText.length > 100 ? '${zikrText.substring(0, 100)}...' : zikrText,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.zikrId,
      );
    }
  }

  DateTime _calculateNextScheduledTime(Reminder reminder) {
    final now = DateTime.now();

    if (reminder.type == ReminderType.fixedDaily && reminder.fixedTime != null) {
      var scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        reminder.fixedTime!.hour,
        reminder.fixedTime!.minute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      return scheduled;
    } else if (reminder.type == ReminderType.interval &&
        reminder.intervalMinutes != null) {
      if (reminder.lastScheduledTime != null) {
        return reminder.lastScheduledTime!
            .add(Duration(minutes: reminder.intervalMinutes!));
      } else {
        return now.add(Duration(minutes: reminder.intervalMinutes!));
      }
    }

    return now.add(const Duration(hours: 1));
  }

  Future<void> cancelReminder(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // This will be handled by the app router
    // The payload contains the zikr ID
    if (response.payload != null) {
      // Navigate to player screen with zikr ID
      // This will be implemented in the presentation layer
    }
  }

  /// Get notification tap handler callback
  Function(NotificationResponse)? get onNotificationTapped => _onNotificationTapped;

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
