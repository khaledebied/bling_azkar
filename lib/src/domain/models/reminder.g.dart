// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReminderImpl _$$ReminderImplFromJson(Map<String, dynamic> json) =>
    _$ReminderImpl(
      id: json['id'] as String,
      zikrId: json['zikrId'] as String,
      title: json['title'] as String,
      isActive: json['isActive'] as bool,
      type: $enumDecode(_$ReminderTypeEnumMap, json['type']),
      fixedTime: json['fixedTime'] == null
          ? null
          : DateTime.parse(json['fixedTime'] as String),
      intervalMinutes: (json['intervalMinutes'] as num?)?.toInt(),
      lastScheduledTime: json['lastScheduledTime'] == null
          ? null
          : DateTime.parse(json['lastScheduledTime'] as String),
      notificationId: (json['notificationId'] as num?)?.toInt(),
      sheikhId: json['sheikhId'] as String,
    );

Map<String, dynamic> _$$ReminderImplToJson(_$ReminderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'zikrId': instance.zikrId,
      'title': instance.title,
      'isActive': instance.isActive,
      'type': _$ReminderTypeEnumMap[instance.type]!,
      'fixedTime': instance.fixedTime?.toIso8601String(),
      'intervalMinutes': instance.intervalMinutes,
      'lastScheduledTime': instance.lastScheduledTime?.toIso8601String(),
      'notificationId': instance.notificationId,
      'sheikhId': instance.sheikhId,
    };

const _$ReminderTypeEnumMap = {
  ReminderType.fixedDaily: 'fixedDaily',
  ReminderType.interval: 'interval',
};
