import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
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

    // Initialize timezone database
    tz_data.initializeTimeZones();
    
    // Set local timezone based on device
    await _setLocalTimezone();

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
    debugPrint('✅ NotificationService initialized with timezone: ${tz.local.name}');
  }

  /// Set local timezone based on device's timezone
  Future<void> _setLocalTimezone() async {
    try {
      // Get the device's timezone offset
      final now = DateTime.now();
      final timeZoneOffset = now.timeZoneOffset;
      
      // Try to find a matching timezone
      String timezoneName = _getTimezoneNameFromOffset(timeZoneOffset);
      
      try {
        tz.setLocalLocation(tz.getLocation(timezoneName));
        debugPrint('📍 Timezone set to: $timezoneName (offset: ${timeZoneOffset.inHours}h)');
      } catch (e) {
        // Fallback to UTC if timezone not found
        debugPrint('⚠️ Could not set timezone $timezoneName, using UTC offset calculation');
        // Use a generic timezone based on offset
        final offsetHours = timeZoneOffset.inHours;
        final fallbackTimezone = _getFallbackTimezone(offsetHours);
        try {
          tz.setLocalLocation(tz.getLocation(fallbackTimezone));
          debugPrint('📍 Timezone fallback to: $fallbackTimezone');
        } catch (e2) {
          // Last resort: use UTC
          tz.setLocalLocation(tz.UTC);
          debugPrint('⚠️ Using UTC as fallback timezone');
        }
      }
    } catch (e) {
      debugPrint('❌ Error setting timezone: $e');
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Get timezone name from offset
  String _getTimezoneNameFromOffset(Duration offset) {
    final hours = offset.inHours;
    final minutes = offset.inMinutes % 60;
    
    // Common timezone mappings
    final timezoneMap = {
      3: 'Asia/Riyadh',      // Saudi Arabia, Kuwait, etc.
      4: 'Asia/Dubai',       // UAE, Oman
      2: 'Africa/Cairo',     // Egypt
      1: 'Europe/Paris',     // Central Europe
      0: 'Europe/London',    // UK
      -5: 'America/New_York', // US Eastern
      -8: 'America/Los_Angeles', // US Pacific
      5: 'Asia/Karachi',     // Pakistan
      330: 'Asia/Kolkata',   // India (5:30 - using minutes)
      8: 'Asia/Singapore',   // Singapore, Malaysia
      9: 'Asia/Tokyo',       // Japan
      -3: 'America/Sao_Paulo', // Brazil
    };
    
    // Check for special cases with minutes (like India 5:30)
    final totalMinutes = offset.inMinutes;
    if (totalMinutes == 330) return 'Asia/Kolkata';
    if (totalMinutes == 345) return 'Asia/Kathmandu'; // Nepal 5:45
    if (totalMinutes == 210) return 'Asia/Tehran'; // Iran 3:30
    
    return timezoneMap[hours] ?? 'Etc/GMT${hours >= 0 ? '-' : '+'}${hours.abs()}';
  }

  /// Get fallback timezone based on offset
  String _getFallbackTimezone(int offsetHours) {
    // Etc/GMT uses inverted signs (Etc/GMT-5 is UTC+5)
    if (offsetHours >= 0) {
      return 'Etc/GMT-$offsetHours';
    } else {
      return 'Etc/GMT+${offsetHours.abs()}';
    }
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
    if (Platform.isAndroid) {
    if (await Permission.scheduleExactAlarm.isDenied) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
      if (!exactAlarmStatus.isGranted) {
        debugPrint('⚠️ Exact alarm permission denied - notifications may not work reliably');
        }
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
          payload: 'zikr_reminder',
          );
          notificationCount++;
          notificationId++;
          
          // Prevent ID overflow
          if (notificationId > 5000) {
            notificationId = 1000;
          }
        } catch (e) {
          debugPrint('Error scheduling notification $notificationId: $e');
        }
      }
    }

    debugPrint('✅ Successfully scheduled $notificationCount notifications every $intervalMinutes minutes');
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

    debugPrint('📅 Current local time: ${now.toString()}');
    debugPrint('📅 Timezone: ${tz.local.name}');

    // Schedule notifications for each time
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

        // Calculate the next occurrence of this time
        // First, create the time for today
        var scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          hour,
          minute,
          0, // seconds
        );

        // If the time has already passed today, schedule for tomorrow
        // This ensures the FIRST notification fires at the correct time
        if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
          debugPrint('📅 Time $timeStr has passed today, scheduling for tomorrow');
        } else {
          debugPrint('📅 Time $timeStr has NOT passed yet, scheduling for today');
        }

        final minutesUntil = scheduledDate.difference(now).inMinutes;
        final hoursUntil = minutesUntil ~/ 60;
        final remainingMinutes = minutesUntil % 60;

        debugPrint('📅 Scheduling daily notification for $timeStr');
        debugPrint('   → First notification: ${scheduledDate.toString()}');
        debugPrint('   → Current time: ${now.toString()}');
        debugPrint('   → Time until first notification: ${hoursUntil}h ${remainingMinutes}m');
        debugPrint('   → Will repeat daily at $timeStr');

        // Schedule the notification with daily repetition
        // matchDateTimeComponents: DateTimeComponents.time means:
        // - The notification will fire at the specified hour:minute every day
        // - The first notification fires at scheduledDate
        // - Subsequent notifications fire daily at the same time
        await _notifications.zonedSchedule(
          notificationId,
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

    debugPrint('✅ Successfully scheduled $scheduledCount daily notification(s)');
    debugPrint('📝 Scheduled times: ${times.join(", ")}');
    
    // Verify scheduled notifications
    await _debugPendingNotifications();
  }

  /// Debug method to list pending notifications
  Future<void> _debugPendingNotifications() async {
    try {
      final pending = await _notifications.pendingNotificationRequests();
      final scheduledPending = pending.where((n) => n.id >= 2000 && n.id < 5000).toList();
      debugPrint('📋 Total scheduled notifications pending: ${scheduledPending.length}');
      
      for (final notification in scheduledPending.take(10)) {
        debugPrint('   - ID: ${notification.id}, Title: ${notification.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ℹ️ Note: Cannot verify scheduled notifications (plugin limitation)');
      }
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
      debugPrint('⚠️ Could not verify pending notifications, rescheduling to be safe: $e');
      await scheduleDailyNotifications(times: times);
    }
  }

  /// Debug method to list all pending scheduled notifications
  Future<void> debugListScheduledNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    final now = tz.TZDateTime.now(tz.local);
    debugPrint('🕐 Current time: ${now.toString()}');
    debugPrint('🌍 Timezone: ${tz.local.name}');

    try {
      final pending = await _notifications.pendingNotificationRequests();
      final scheduledPending = pending.where((n) => n.id >= 2000 && n.id < 5000).toList();
      
      debugPrint('🔍 Debug: Found ${scheduledPending.length} scheduled notifications:');
      for (final notification in scheduledPending) {
        debugPrint('   - ID: ${notification.id}, Title: "${notification.title}", Body: "${notification.body}"');
      }
    } catch (e) {
      debugPrint('❌ Could not list scheduled notifications: $e');
    }
    
    // Check permissions
    final notificationPermission = await Permission.notification.status;
    debugPrint('🔐 Notification permission: $notificationPermission');
    
    if (Platform.isAndroid) {
    final exactAlarmPermission = await Permission.scheduleExactAlarm.status;
      debugPrint('🔐 Exact alarm permission: $exactAlarmPermission');
    }
  }

  /// Schedule a test notification in 1 minute to verify notifications are working
  /// Returns the scheduled time as a string for display
  Future<String> scheduleTestNotificationIn1Minute() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Verify permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Notification permission not granted');
    }

    const androidDetails = AndroidNotificationDetails(
      'test_scheduled',
      'Test Scheduled Notifications',
      channelDescription: 'Test for scheduled notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
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
    final scheduledDate = now.add(const Duration(minutes: 1));

    debugPrint('🧪 Scheduling test notification');
    debugPrint('   → Current time: ${now.toString()}');
    debugPrint('   → Scheduled for: ${scheduledDate.toString()}');

    await _notifications.zonedSchedule(
      9999, // Unique ID for test notification
      '🧪 Test Notification',
      'If you see this, notifications are working correctly!',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'test_notification',
    );

    final timeStr = '${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}';
    debugPrint('✅ Test notification scheduled for $timeStr');
    
    return timeStr;
  }

  /// Cancel test notification
  Future<void> cancelTestNotification() async {
    await _notifications.cancel(9999);
  }

  /// Schedule prayer time notifications
  /// prayerTimes: Map of prayer name to DateTime (e.g., {'fajr': DateTime, 'dhuhr': DateTime, ...})
  /// isArabic: Whether to use Arabic language for notifications
  Future<void> schedulePrayerTimeNotifications({
    required Map<String, DateTime> prayerTimes,
    required bool isArabic,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (prayerTimes.isEmpty) {
      debugPrint('No prayer times provided');
      return;
    }

    // Verify permissions before scheduling
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('❌ Notification permission not granted for prayer times');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'prayer_time_reminders',
      'Prayer Time Reminders',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      ongoing: false,
      channelShowBadge: true,
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

    // Cancel existing prayer notifications first
    await cancelPrayerTimeNotifications();

    final now = tz.TZDateTime.now(tz.local);
    int notificationId = 5000; // Start from 5000 for prayer notifications
    int scheduledCount = 0;

    // Prayer name translations
    final prayerNamesAr = {
      'fajr': 'الفجر',
      'dhuhr': 'الظهر',
      'asr': 'العصر',
      'maghrib': 'المغرب',
      'isha': 'العشاء',
    };

    final prayerNamesEn = {
      'fajr': 'Fajr',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
    };

    debugPrint('📿 Scheduling prayer time notifications...');
    debugPrint('   Current time: ${now.toString()}');

    for (final entry in prayerTimes.entries) {
      final prayerKey = entry.key;
      final prayerDateTime = entry.value;

      try {
        // Convert to TZDateTime
        var scheduledDate = tz.TZDateTime(
          tz.local,
          prayerDateTime.year,
          prayerDateTime.month,
          prayerDateTime.day,
          prayerDateTime.hour,
          prayerDateTime.minute,
          0,
        );

        // If the time has already passed today, schedule for tomorrow
        if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        final prayerNameAr = prayerNamesAr[prayerKey] ?? prayerKey;
        final prayerNameEn = prayerNamesEn[prayerKey] ?? prayerKey;

        final title = isArabic ? 'حان وقت صلاة $prayerNameAr' : '$prayerNameEn Prayer Time';
        final body = isArabic 
            ? 'حان الآن موعد صلاة $prayerNameAr 🕌'
            : 'It\'s time for $prayerNameEn prayer 🕌';

        final minutesUntil = scheduledDate.difference(now).inMinutes;
        debugPrint('   📿 $prayerKey: ${scheduledDate.toString()} (in ${minutesUntil}m)');

        await _notifications.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'prayer_time_$prayerKey',
          matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
        );

        scheduledCount++;
        notificationId++;
      } catch (e) {
        debugPrint('❌ Error scheduling $prayerKey notification: $e');
      }
    }

    debugPrint('✅ Scheduled $scheduledCount prayer time notifications');
  }

  /// Cancel only prayer time notifications (IDs 5000-5999)
  Future<void> cancelPrayerTimeNotifications() async {
    try {
      final pending = await _notifications.pendingNotificationRequests();
      for (final notification in pending) {
        if (notification.id >= 5000 && notification.id < 6000) {
          await _notifications.cancel(notification.id);
        }
      }
      debugPrint('Cancelled prayer time notifications');
    } catch (e) {
      debugPrint('⚠️ Could not get pending notifications, cancelling by ID range: $e');
      for (int id = 5000; id < 6000; id++) {
        try {
          await _notifications.cancel(id);
        } catch (_) {
          // Ignore individual cancel errors
        }
      }
    }
  }

  /// Reschedule prayer time notifications if needed
  Future<void> reschedulePrayerTimeNotificationsIfNeeded({
    required Map<String, DateTime> prayerTimes,
    required bool isArabic,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (prayerTimes.isEmpty) {
      return;
    }

    try {
      final pending = await _notifications.pendingNotificationRequests();
      final prayerPending = pending.where((n) => n.id >= 5000 && n.id < 6000).toList();
      
      // We should have 5 notifications (one per prayer)
      if (prayerPending.length < 5) {
        debugPrint('⚠️ Low prayer notification count (${prayerPending.length}/5), rescheduling...');
        await schedulePrayerTimeNotifications(
          prayerTimes: prayerTimes,
          isArabic: isArabic,
        );
      } else {
        debugPrint('✅ Prayer time notifications are up to date');
      }
    } catch (e) {
      debugPrint('⚠️ Could not verify prayer notifications, rescheduling: $e');
      await schedulePrayerTimeNotifications(
        prayerTimes: prayerTimes,
        isArabic: isArabic,
      );
    }
  }
}
