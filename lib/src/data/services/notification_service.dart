import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/models/reminder.dart';
import '../../../main.dart';
import '../../utils/page_transitions.dart';
import '../repositories/azkar_repository.dart';
import 'reminder_service.dart';
import '../../presentation/screens/player_screen.dart';

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

    // Create Android notification channel
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      const androidChannel = AndroidNotificationChannel(
        'azkar_reminders',
        'Azkar Reminders',
        description: 'Local reminders for daily Azkar',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      
      await androidImplementation.createNotificationChannel(androidChannel);
      print('Android notification channel created');
    }

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

    final initialized = await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (initialized != null && initialized) {
      _initialized = true;
      print('NotificationService initialized successfully');
    } else {
      print('NotificationService initialization failed');
    }
  }

  Future<bool> requestPermissions() async {
    if (!_initialized) {
      await initialize();
    }

    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    bool androidGranted = true;
    bool iosGranted = true;

    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      androidGranted = granted ?? false;
      print('Android notification permission: $androidGranted');
    }

    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      iosGranted = granted ?? false;
      print('iOS notification permission: $iosGranted');
    }

    final result = androidGranted && iosGranted;
    print('Notification permissions granted: $result');
    return result;
  }

  Future<void> scheduleReminder(
    Reminder reminder,
    String zikrTitle,
    String zikrText,
  ) async {
    if (!_initialized) {
      await initialize();
    }

    // Request permissions before scheduling
    await requestPermissions();

    final notificationId = reminder.notificationId ?? DateTime.now().millisecondsSinceEpoch % 2147483647;
    await _notifications.cancel(notificationId);

    final DateTime scheduledTime = _calculateNextScheduledTime(reminder);
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    print('Scheduling notification:');
    print('  ID: $notificationId');
    print('  Title: $zikrTitle');
    print('  Scheduled for: $scheduledTime');
    print('  Type: ${reminder.type}');
    print('  Time until notification: ${scheduledTime.difference(DateTime.now()).inMinutes} minutes');

    final androidDetails = AndroidNotificationDetails(
      'azkar_reminders',
      'Azkar Reminders',
      channelDescription: 'Local reminders for daily Azkar',
      importance: Importance.high,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('short_zikr_1'),
      enableVibration: true,
      playSound: true,
      ongoing: false,
      autoCancel: true,
      showWhen: true,
      when: scheduledTime.millisecondsSinceEpoch,
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

    try {
      if (reminder.type == ReminderType.fixedDaily) {
        // Schedule daily repeating notification
        await _notifications.zonedSchedule(
          notificationId,
          zikrTitle,
          zikrText.length > 100 ? '${zikrText.substring(0, 100)}...' : zikrText,
          tzScheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: reminder.zikrId,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        print('Daily reminder scheduled successfully');
      } else {
        // Schedule one-time notification for interval reminders
        await _notifications.zonedSchedule(
          notificationId,
          zikrTitle,
          zikrText.length > 100 ? '${zikrText.substring(0, 100)}...' : zikrText,
          tzScheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: reminder.zikrId,
        );
        print('Interval reminder scheduled successfully');
      }

      // Verify the notification was scheduled
      final pending = await _notifications.pendingNotificationRequests();
      print('Total pending notifications: ${pending.length}');
      final ourNotification = pending.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => throw Exception('Notification not found in pending list'),
      );
      print('Our notification found: ${ourNotification.title}');
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
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

      // If the time has passed today, schedule for tomorrow
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      print('Fixed daily reminder scheduled for: $scheduled');
      return scheduled;
    } else if (reminder.type == ReminderType.interval &&
        reminder.intervalMinutes != null) {
      DateTime scheduled;
      
      if (reminder.lastScheduledTime != null) {
        // Schedule from last scheduled time
        scheduled = reminder.lastScheduledTime!
            .add(Duration(minutes: reminder.intervalMinutes!));
        
        // If that time is in the past, schedule from now instead
        if (scheduled.isBefore(now)) {
          scheduled = now.add(Duration(minutes: reminder.intervalMinutes!));
        }
      } else {
        // First time scheduling - schedule from now
        scheduled = now.add(Duration(minutes: reminder.intervalMinutes!));
      }

      print('Interval reminder scheduled for: $scheduled (in ${scheduled.difference(now).inMinutes} minutes)');
      return scheduled;
    }

    // Fallback: schedule 1 hour from now
    return now.add(const Duration(hours: 1));
  }

  Future<void> cancelReminder(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  void _onNotificationTapped(NotificationResponse response) async {
    print('Notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      final zikrId = response.payload!;
      
      // Reschedule interval reminder if needed
      final reminderService = ReminderService();
      await reminderService.rescheduleAfterNotification(zikrId);
      
      // Navigate to player screen
      if (navigatorKey.currentContext != null) {
        final azkarRepo = AzkarRepository();
        final zikr = await azkarRepo.getZikrById(zikrId);
        if (zikr != null) {
          Navigator.of(navigatorKey.currentContext!).push(
            CustomPageRoute(
              child: PlayerScreen(zikr: zikr),
            ),
          );
        }
      }
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Test notification - schedule one immediately for testing
  Future<void> showTestNotification(String title, String body) async {
    if (!_initialized) {
      await initialize();
    }

    await requestPermissions();

    const androidDetails = AndroidNotificationDetails(
      'azkar_reminders',
      'Azkar Reminders',
      channelDescription: 'Local reminders for daily Azkar',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999999,
      title,
      body,
      details,
    );
  }
}
