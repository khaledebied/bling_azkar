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
    try {
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
    } catch (e) {
      // Known issue: pendingNotificationRequests can fail with "Missing type parameter" 
      // when notifications are scheduled with matchDateTimeComponents
      // Reschedule to be safe
      debugPrint('⚠️ Could not check pending notifications, rescheduling: $e');
      await _cancelAllNotifications();
      await _scheduleMultipleNotifications(
        title: 'وقت الذكر',
        body: 'لا تنسى ذكر الله ❤️',
        intervalMinutes: 10,
        hoursAhead: 12,
      );
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
      // Removed icon specification - Android will use app icon by default
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
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
    
    // Verify scheduled notifications (wrapped in try-catch due to known plugin issue)
    try {
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('📋 Total pending notifications: ${pending.length}');
    } catch (e) {
      debugPrint('⚠️ Could not verify pending notifications (this is expected): $e');
    }
  }

  // Reschedule notifications when app comes to foreground
  Future<void> rescheduleIfNeeded() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final pendingNotifications = await _notifications.pendingNotificationRequests();
      
      // If we have less than 20 pending notifications, reschedule
      if (pendingNotifications.length < 20) {
        debugPrint('⚠️ Low notification count (${pendingNotifications.length}), rescheduling...');
        await startPeriodicReminders();
      } else {
        debugPrint('✅ Notifications are up to date (${pendingNotifications.length} pending)');
      }
    } catch (e) {
      // Known issue: pendingNotificationRequests can fail with "Missing type parameter" 
      // when notifications are scheduled with matchDateTimeComponents
      // Reschedule to be safe
      debugPrint('⚠️ Could not check pending notifications, rescheduling: $e');
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
      // Removed icon specification - Android will use app icon by default
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
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
      // Removed icon specification - Android will use app icon by default
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
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

  /// Schedule daily notifications at specific times
  /// times: List of time strings in format "HH:mm" (e.g., ["08:00", "12:30", "18:00"])
  Future<void> scheduleDailyNotifications({
    required List<String> times,
    String title = 'وقت الذكر',
    String body = 'لا تنسى ذكر الله ❤️',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (times.isEmpty) {
      debugPrint('No scheduled times provided, cancelling scheduled notifications');
      await cancelScheduledNotifications();
      return;
    }

    // Verify permissions before scheduling
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('❌ Notification permission not granted, cannot schedule notifications');
      return;
    }

    // Check exact alarm permission (required for exact scheduling on Android 12+)
    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    if (exactAlarmStatus.isDenied) {
      debugPrint('⚠️ Exact alarm permission not granted - notifications may not work reliably');
      debugPrint('⚠️ Please grant exact alarm permission in device settings for reliable notifications');
    }

    const androidDetails = AndroidNotificationDetails(
      'scheduled_zikr_reminders',
      'Scheduled Zikr Reminders',
      channelDescription: 'Daily scheduled reminders to remember Allah',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      ongoing: false,
      channelShowBadge: true,
      // Removed icon specification - Android will use app icon by default
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
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

    // Cancel existing scheduled notifications first
    await cancelScheduledNotifications();

    final now = tz.TZDateTime.now(tz.local);
    int notificationId = 2000; // Start from 2000 to avoid conflicts with periodic reminders
    int scheduledCount = 0;

    // Schedule one notification per time (matchDateTimeComponents will handle daily repetition)
    for (final timeStr in times) {
      try {
        final timeParts = timeStr.split(':');
        if (timeParts.length != 2) {
          debugPrint('⚠️ Invalid time format: $timeStr (expected HH:mm)');
          continue;
        }

        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);

        if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
          debugPrint('⚠️ Invalid time values: $timeStr');
          continue;
        }

        // Calculate the scheduled date for today
        final scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        // If the time has passed today, schedule for tomorrow
        final targetDate = scheduledDate.isBefore(now) 
            ? scheduledDate.add(const Duration(days: 1))
            : scheduledDate;

        debugPrint('📅 Scheduling notification for $timeStr at ${targetDate.toString()}');

        await _scheduleSingleNotification(
          notificationId,
          title,
          body,
          targetDate,
          details,
        );
        
        scheduledCount++;
        notificationId++;

        // Prevent ID overflow
        if (notificationId > 4000) {
          notificationId = 2000;
        }
      } catch (e) {
        debugPrint('❌ Error scheduling notification for time $timeStr: $e');
      }
    }

    debugPrint('✅ Successfully scheduled $scheduledCount daily notification(s) at ${times.length} time(s)');
    debugPrint('📝 Scheduled times: ${times.join(", ")}');
    
    // Verify scheduled notifications (wrapped in try-catch due to known plugin issue)
    try {
      final pending = await _notifications.pendingNotificationRequests();
      final scheduledPending = pending.where((n) => n.id >= 2000 && n.id < 5000).toList();
      debugPrint('📋 Total scheduled notifications pending: ${scheduledPending.length}');
      
      // Log details of pending notifications for debugging
      for (final notification in scheduledPending.take(5)) {
        debugPrint('   - ID: ${notification.id}, Title: ${notification.title}');
      }
    } catch (e) {
      // Known issue: pendingNotificationRequests can fail with "Missing type parameter" 
      // when notifications are scheduled with matchDateTimeComponents
      // This doesn't affect the actual scheduling, just the verification
      debugPrint('⚠️ Could not verify pending notifications (this is expected): $e');
    }
  }

  /// Schedule a single notification
  Future<void> _scheduleSingleNotification(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduledDate,
    NotificationDetails details,
  ) async {
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'scheduled_zikr_reminder',
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at this time
      );
    } catch (e) {
      debugPrint('Error scheduling notification $id: $e');
      rethrow;
    }
  }

  /// Cancel only scheduled notifications (IDs 2000-4999)
  Future<void> cancelScheduledNotifications() async {
    try {
      final pending = await _notifications.pendingNotificationRequests();
      for (final notification in pending) {
        if (notification.id >= 2000 && notification.id < 5000) {
          await _notifications.cancel(notification.id);
        }
      }
      debugPrint('Cancelled scheduled notifications');
    } catch (e) {
      // Known issue: pendingNotificationRequests can fail with "Missing type parameter" 
      // when notifications are scheduled with matchDateTimeComponents
      // Cancel all notifications in the ID range as a fallback
      debugPrint('⚠️ Could not get pending notifications, cancelling by ID range: $e');
      for (int id = 2000; id < 5000; id++) {
        try {
          await _notifications.cancel(id);
        } catch (_) {
          // Ignore individual cancel errors
        }
      }
      debugPrint('Cancelled scheduled notifications (fallback method)');
    }
  }

  /// Reschedule daily notifications if needed
  Future<void> rescheduleDailyNotificationsIfNeeded(List<String> times) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (times.isEmpty) {
      return;
    }

    try {
      final pending = await _notifications.pendingNotificationRequests();
      final scheduledPending = pending.where((n) => n.id >= 2000 && n.id < 5000).toList();
      
      // With matchDateTimeComponents, we should have exactly one notification per time
      if (scheduledPending.length < times.length) {
        debugPrint('⚠️ Low scheduled notification count (${scheduledPending.length}/${times.length}), rescheduling...');
        await scheduleDailyNotifications(times: times);
      } else {
        debugPrint('✅ Scheduled notifications are up to date (${scheduledPending.length} notifications)');
      }
    } catch (e) {
      // Known issue: pendingNotificationRequests can fail with "Missing type parameter" 
      // when notifications are scheduled with matchDateTimeComponents
      // Reschedule as a precaution
      debugPrint('⚠️ Could not verify pending notifications, rescheduling to be safe: $e');
      await scheduleDailyNotifications(times: times);
    }
  }

  /// Debug method to list all pending scheduled notifications
  Future<void> debugListScheduledNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final pending = await _notifications.pendingNotificationRequests();
      final scheduledPending = pending.where((n) => n.id >= 2000 && n.id < 5000).toList();
      
      debugPrint('🔍 Debug: Found ${scheduledPending.length} scheduled notifications:');
      for (final notification in scheduledPending) {
        debugPrint('   - ID: ${notification.id}, Title: "${notification.title}", Body: "${notification.body}"');
      }
    } catch (e) {
      debugPrint('❌ Could not list scheduled notifications: $e');
      debugPrint('   This is a known issue with the plugin when using matchDateTimeComponents');
    }
    
    // Check permissions
    final notificationPermission = await Permission.notification.status;
    final exactAlarmPermission = await Permission.scheduleExactAlarm.status;
    debugPrint('🔐 Permissions - Notification: $notificationPermission, Exact Alarm: $exactAlarmPermission');
  }
}

