import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to a specific screen or perform an action
  }

  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    // For Android 13+
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Start periodic reminders every 10 minutes
  Future<void> startPeriodicReminders() async {
    if (!_isInitialized) {
      await initialize();
    }

    await _cancelAllNotifications();

    // Schedule 10-minute reminders
    await _schedulePeriodicNotification(
      id: 1,
      title: 'وقت الذكر',
      body: 'لا تنسى ذكر الله ❤️',
      intervalMinutes: 10,
    );
  }

  Future<void> _schedulePeriodicNotification({
    required int id,
    required String title,
    required String body,
    required int intervalMinutes,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'zikr_reminders',
      'Zikr Reminders',
      channelDescription: 'Periodic reminders to remember Allah',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the first notification after 10 minutes
    final scheduledDate = tz.TZDateTime.now(tz.local).add(
      Duration(minutes: intervalMinutes),
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // For Android, we need to reschedule after each notification
    // This is a workaround for periodic notifications
    _scheduleNextNotification(id, title, body, intervalMinutes);
  }

  Future<void> _scheduleNextNotification(
    int id,
    String title,
    String body,
    int intervalMinutes,
  ) async {
    // This will be called repeatedly to create a chain of notifications
    await Future.delayed(Duration(minutes: intervalMinutes), () async {
      await _schedulePeriodicNotification(
        id: id,
        title: title,
        body: body,
        intervalMinutes: intervalMinutes,
      );
    });
  }

  Future<void> stopPeriodicReminders() async {
    await _cancelAllNotifications();
  }

  Future<void> _cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> showTestNotification(String title, String body) async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      title,
      body,
      details,
    );
  }

  Future<void> scheduleTestNotificationInSeconds(
    String title,
    String body,
    int seconds,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = tz.TZDateTime.now(tz.local).add(
      Duration(seconds: seconds),
    );

    await _notifications.zonedSchedule(
      1,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

