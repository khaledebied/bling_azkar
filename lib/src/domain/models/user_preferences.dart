import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

@freezed
@HiveType(typeId: 4)
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @HiveField(0) @Default('ar') String language,
    @HiveField(1) @Default('sh01') String selectedSheikhId,
    @HiveField(2) @Default(false) bool notificationsEnabled,
    @HiveField(3) @Default([]) List<String> favoriteZikrIds,
    @HiveField(4) DateTime? dndStartTime,
    @HiveField(5) DateTime? dndEndTime,
    @HiveField(6) @Default(false) bool dndEnabled,
    @HiveField(7) @Default(1.0) double textScale,
    @HiveField(9) @Default('system') String themeMode, // 'light', 'dark', 'system'
    @HiveField(10) int? selectedLocationId,
    @HiveField(11) String? selectedLocationName,
    @HiveField(12) double? selectedLocationLatitude,
    @HiveField(13) double? selectedLocationLongitude,
    @HiveField(14) String? selectedLocationCountryCode,
    @HiveField(15) String? selectedLocationCountryName,
    @HiveField(16) @Default([]) List<String> scheduledNotificationTimes, // Format: "HH:mm" (e.g., "08:00", "12:30")
    @HiveField(17) @Default(false) bool prayerTimeNotificationsEnabled, // Notify at each prayer time
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}
