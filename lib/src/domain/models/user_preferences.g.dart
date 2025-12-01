// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$UserPreferencesImpl(
      language: json['language'] as String? ?? 'en',
      selectedSheikhId: json['selectedSheikhId'] as String? ?? 'sh01',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      favoriteZikrIds: (json['favoriteZikrIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dndStartTime: json['dndStartTime'] == null
          ? null
          : DateTime.parse(json['dndStartTime'] as String),
      dndEndTime: json['dndEndTime'] == null
          ? null
          : DateTime.parse(json['dndEndTime'] as String),
      dndEnabled: json['dndEnabled'] as bool? ?? false,
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$UserPreferencesImplToJson(
        _$UserPreferencesImpl instance) =>
    <String, dynamic>{
      'language': instance.language,
      'selectedSheikhId': instance.selectedSheikhId,
      'notificationsEnabled': instance.notificationsEnabled,
      'favoriteZikrIds': instance.favoriteZikrIds,
      'dndStartTime': instance.dndStartTime?.toIso8601String(),
      'dndEndTime': instance.dndEndTime?.toIso8601String(),
      'dndEnabled': instance.dndEnabled,
      'textScale': instance.textScale,
    };
