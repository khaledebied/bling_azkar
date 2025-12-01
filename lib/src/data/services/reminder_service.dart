import 'package:uuid/uuid.dart';
import '../../domain/models/reminder.dart';
import '../../domain/models/zikr.dart';
import 'storage_service.dart';
import 'notification_service.dart';
import '../repositories/azkar_repository.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final _storage = StorageService();
  final _notifications = NotificationService();
  final _azkarRepo = AzkarRepository();
  final _uuid = const Uuid();

  /// Create a new reminder
  Future<Reminder> createReminder({
    required String zikrId,
    required ReminderType type,
    DateTime? fixedTime,
    int? intervalMinutes,
    String? sheikhId,
  }) async {
    final zikr = await _azkarRepo.getZikrById(zikrId);
    if (zikr == null) {
      throw Exception('Zikr not found');
    }

    final reminderId = _uuid.v4();
    final notificationId = DateTime.now().millisecondsSinceEpoch % 2147483647; // Max int32

    final reminder = Reminder(
      id: reminderId,
      zikrId: zikrId,
      title: zikr.title.ar,
      isActive: true,
      type: type,
      fixedTime: fixedTime,
      intervalMinutes: intervalMinutes,
      lastScheduledTime: null,
      notificationId: notificationId,
      sheikhId: sheikhId ?? '',
    );

    await _storage.saveReminder(reminder);
    await _scheduleNotification(reminder, zikr);

    return reminder;
  }

  /// Update an existing reminder
  Future<Reminder> updateReminder(Reminder reminder) async {
    await _storage.saveReminder(reminder);
    
    if (reminder.isActive) {
      final zikr = await _azkarRepo.getZikrById(reminder.zikrId);
      if (zikr != null) {
        await _scheduleNotification(reminder, zikr);
      }
    } else {
      await _notifications.cancelReminder(reminder.notificationId ?? 0);
    }

    return reminder;
  }

  /// Toggle reminder active state
  Future<Reminder> toggleReminder(String reminderId) async {
    final reminder = _storage.getReminder(reminderId);
    if (reminder == null) {
      throw Exception('Reminder not found');
    }

    final updated = reminder.copyWith(isActive: !reminder.isActive);
    return await updateReminder(updated);
  }

  /// Delete a reminder
  Future<void> deleteReminder(String reminderId) async {
    final reminder = _storage.getReminder(reminderId);
    if (reminder != null && reminder.notificationId != null) {
      await _notifications.cancelReminder(reminder.notificationId!);
    }
    await _storage.deleteReminder(reminderId);
  }

  /// Get all reminders
  List<Reminder> getAllReminders() {
    return _storage.getAllReminders();
  }

  /// Get reminders for a specific zikr
  List<Reminder> getRemindersForZikr(String zikrId) {
    return getAllReminders().where((r) => r.zikrId == zikrId).toList();
  }

  /// Get active reminders
  List<Reminder> getActiveReminders() {
    return getAllReminders().where((r) => r.isActive).toList();
  }

  /// Schedule notification for a reminder
  Future<void> _scheduleNotification(Reminder reminder, Zikr zikr) async {
    if (!reminder.isActive) return;

    await _notifications.scheduleReminder(
      reminder,
      reminder.title,
      zikr.text,
    );

    // Update last scheduled time only for interval reminders
    if (reminder.type == ReminderType.interval) {
      final now = DateTime.now();
      final updated = reminder.copyWith(lastScheduledTime: now);
      await _storage.saveReminder(updated);
    }
  }

  /// Reschedule all active reminders (useful after app restart)
  Future<void> rescheduleAllActiveReminders() async {
    final activeReminders = getActiveReminders();
    
    for (final reminder in activeReminders) {
      final zikr = await _azkarRepo.getZikrById(reminder.zikrId);
      if (zikr != null) {
        await _scheduleNotification(reminder, zikr);
      }
    }
  }

  /// Reschedule a reminder after notification fires (for interval reminders)
  Future<void> rescheduleAfterNotification(String reminderId) async {
    final reminder = _storage.getReminder(reminderId);
    if (reminder == null || !reminder.isActive) return;

    // Only reschedule interval reminders
    if (reminder.type == ReminderType.interval) {
      final zikr = await _azkarRepo.getZikrById(reminder.zikrId);
      if (zikr != null) {
        await _scheduleNotification(reminder, zikr);
      }
    }
  }

  /// Check if a zikr has an active reminder
  bool hasActiveReminder(String zikrId) {
    return getRemindersForZikr(zikrId).any((r) => r.isActive);
  }
}

