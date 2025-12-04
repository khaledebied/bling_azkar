import 'package:flutter/foundation.dart';
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
  
  // Callback for notification tap handling
  Function(NotificationResponse)? onNotificationTapped;

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
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    
    // Call the callback if set
    if (onNotificationTapped != null) {
      onNotificationTapped!(response);
    }
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    debugPrint('Notification tapped in background: ${response.payload}');
    // Background notification tap handling
    NotificationService()._onNotificationTapped(response);
  }

  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    // For Android 13+ - request notification permission
    final notificationStatus = await Permission.notification.request();
    
    // For Android 12+ - request exact alarm permission (required for exact scheduling)
    if (await Permission.scheduleExactAlarm.isDenied) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
      if (!exactAlarmStatus.isGranted) {
        debugPrint('⚠️ Exact alarm permission denied - notifications may not work reliably');
      }
    }
    
    return notificationStatus.isGranted;
  }

  // Start periodic reminders every 10 minutes
  Future<void> startPeriodicReminders() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Don't cancel all - check if we need to reschedule
    final pendingNotifications = await _notifications.pendingNotificationRequests();
    
    // If we have less than 50 pending notifications, reschedule
    if (pendingNotifications.length < 50) {
      await _cancelAllNotifications();

      // Schedule notifications for the next 12 hours (72 notifications every 10 minutes)
      // This ensures we don't hit Android's notification limit
      await _scheduleMultipleNotifications(
        title: 'وقت الذكر',
        body: 'لا تنسى ذكر الله ❤️',
        intervalMinutes: 10,
        hoursAhead: 12, // Schedule for next 12 hours
      );
    } else {
      debugPrint('Notifications already scheduled (${pendingNotifications.length} pending)');
    }
  }

  Future<void> _scheduleMultipleNotifications({
    required String title,
    required String body,
    required int intervalMinutes,
    required int hoursAhead,
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
      ongoing: false,
      channelShowBadge: true,
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

    final now = tz.TZDateTime.now(tz.local);
    final endTime = now.add(Duration(hours: hoursAhead));
    int notificationId = 1000; // Start from 1000 to avoid conflicts
    int notificationCount = 0;

    // Calculate how many notifications we need
    final totalNotifications = (hoursAhead * 60 / intervalMinutes).ceil();

    debugPrint('Starting to schedule $totalNotifications notifications...');

    // Schedule all notifications
    for (int i = 0; i < totalNotifications; i++) {
      final scheduledDate = now.add(Duration(minutes: intervalMinutes * (i + 1)));
      
      // Only schedule if within the time range and in the future
      if (scheduledDate.isAfter(now) && 
          (scheduledDate.isBefore(endTime) || scheduledDate.isAtSameMomentAs(endTime))) {
        try {
        await _notifications.zonedSchedule(
          notificationId,
            title,
            body,
            scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'zikr_reminder', // Payload to identify zikr reminder notifications
          );
          notificationCount++;
          notificationId++;
          
          // Prevent ID overflow (Android typically supports up to 5000)
          if (notificationId > 5000) {
            notificationId = 1000;
          }
          
          // Log progress every 10 notifications
          if (notificationCount % 10 == 0) {
            debugPrint('Scheduled $notificationCount/$totalNotifications notifications...');
          }
        } catch (e) {
          debugPrint('Error scheduling notification $notificationId: $e');
        }
      }
    }

    debugPrint('✅ Successfully scheduled $notificationCount notifications every $intervalMinutes minutes for the next $hoursAhead hours');
    
    // Verify scheduled notifications
    final pending = await _notifications.pendingNotificationRequests();
    debugPrint('📋 Total pending notifications: ${pending.length}');
  }

  // Reschedule notifications when app comes to foreground
  Future<void> rescheduleIfNeeded() async {
    if (!_isInitialized) {
      await initialize();
    }

    final pendingNotifications = await _notifications.pendingNotificationRequests();
    
    // If we have less than 20 pending notifications, reschedule
    if (pendingNotifications.length < 20) {
      debugPrint('⚠️ Low notification count (${pendingNotifications.length}), rescheduling...');
      await startPeriodicReminders();
    }
  }

  // Get initial notification when app is opened from notification
  Future<NotificationResponse?> getInitialNotification() async {
    if (!_isInitialized) {
      await initialize();
    }
    final launchDetails = await _notifications.getNotificationAppLaunchDetails();
    return launchDetails?.notificationResponse;
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

