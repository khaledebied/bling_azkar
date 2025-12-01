import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

@freezed
@HiveType(typeId: 4)
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @HiveField(0) @Default('en') String language,
    @HiveField(1) @Default('sh01') String selectedSheikhId,
    @HiveField(2) @Default(false) bool notificationsEnabled,
    @HiveField(3) @Default([]) List<String> favoriteZikrIds,
    @HiveField(4) DateTime? dndStartTime,
    @HiveField(5) DateTime? dndEndTime,
    @HiveField(6) @Default(false) bool dndEnabled,
    @HiveField(7) @Default(1.0) double textScale,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}
