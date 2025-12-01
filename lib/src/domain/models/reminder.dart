import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

@freezed
@HiveType(typeId: 0)
class Reminder with _$Reminder {
  const factory Reminder({
    @HiveField(0) required String id,
    @HiveField(1) required String zikrId,
    @HiveField(2) required String title,
    @HiveField(3) required bool isActive,
    @HiveField(4) required ReminderType type,
    @HiveField(5) required DateTime? fixedTime,
    @HiveField(6) required int? intervalMinutes,
    @HiveField(7) required DateTime? lastScheduledTime,
    @HiveField(8) required int? notificationId,
    @HiveField(9) required String sheikhId,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}

@HiveType(typeId: 1)
enum ReminderType {
  @HiveField(0)
  fixedDaily,
  @HiveField(1)
  interval,
}
