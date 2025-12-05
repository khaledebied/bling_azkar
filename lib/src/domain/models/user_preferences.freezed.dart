// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return _UserPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserPreferences {
  @HiveField(0)
  String get language => throw _privateConstructorUsedError;
  @HiveField(1)
  String get selectedSheikhId => throw _privateConstructorUsedError;
  @HiveField(2)
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  @HiveField(3)
  List<String> get favoriteZikrIds => throw _privateConstructorUsedError;
  @HiveField(4)
  DateTime? get dndStartTime => throw _privateConstructorUsedError;
  @HiveField(5)
  DateTime? get dndEndTime => throw _privateConstructorUsedError;
  @HiveField(6)
  bool get dndEnabled => throw _privateConstructorUsedError;
  @HiveField(7)
  double get textScale => throw _privateConstructorUsedError;
  @HiveField(9)
  String get themeMode =>
      throw _privateConstructorUsedError; // 'light', 'dark', 'system'
  @HiveField(10)
  int? get selectedLocationId => throw _privateConstructorUsedError;
  @HiveField(11)
  String? get selectedLocationName => throw _privateConstructorUsedError;
  @HiveField(12)
  double? get selectedLocationLatitude => throw _privateConstructorUsedError;
  @HiveField(13)
  double? get selectedLocationLongitude => throw _privateConstructorUsedError;
  @HiveField(14)
  String? get selectedLocationCountryCode => throw _privateConstructorUsedError;
  @HiveField(15)
  String? get selectedLocationCountryName => throw _privateConstructorUsedError;
  @HiveField(16)
  List<String> get scheduledNotificationTimes =>
      throw _privateConstructorUsedError;

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
          UserPreferences value, $Res Function(UserPreferences) then) =
      _$UserPreferencesCopyWithImpl<$Res, UserPreferences>;
  @useResult
  $Res call(
      {@HiveField(0) String language,
      @HiveField(1) String selectedSheikhId,
      @HiveField(2) bool notificationsEnabled,
      @HiveField(3) List<String> favoriteZikrIds,
      @HiveField(4) DateTime? dndStartTime,
      @HiveField(5) DateTime? dndEndTime,
      @HiveField(6) bool dndEnabled,
      @HiveField(7) double textScale,
      @HiveField(9) String themeMode,
      @HiveField(10) int? selectedLocationId,
      @HiveField(11) String? selectedLocationName,
      @HiveField(12) double? selectedLocationLatitude,
      @HiveField(13) double? selectedLocationLongitude,
      @HiveField(14) String? selectedLocationCountryCode,
      @HiveField(15) String? selectedLocationCountryName,
      @HiveField(16) List<String> scheduledNotificationTimes});
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res, $Val extends UserPreferences>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? language = null,
    Object? selectedSheikhId = null,
    Object? notificationsEnabled = null,
    Object? favoriteZikrIds = null,
    Object? dndStartTime = freezed,
    Object? dndEndTime = freezed,
    Object? dndEnabled = null,
    Object? textScale = null,
    Object? themeMode = null,
    Object? selectedLocationId = freezed,
    Object? selectedLocationName = freezed,
    Object? selectedLocationLatitude = freezed,
    Object? selectedLocationLongitude = freezed,
    Object? selectedLocationCountryCode = freezed,
    Object? selectedLocationCountryName = freezed,
    Object? scheduledNotificationTimes = null,
  }) {
    return _then(_value.copyWith(
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      selectedSheikhId: null == selectedSheikhId
          ? _value.selectedSheikhId
          : selectedSheikhId // ignore: cast_nullable_to_non_nullable
              as String,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      favoriteZikrIds: null == favoriteZikrIds
          ? _value.favoriteZikrIds
          : favoriteZikrIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dndStartTime: freezed == dndStartTime
          ? _value.dndStartTime
          : dndStartTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dndEndTime: freezed == dndEndTime
          ? _value.dndEndTime
          : dndEndTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dndEnabled: null == dndEnabled
          ? _value.dndEnabled
          : dndEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      textScale: null == textScale
          ? _value.textScale
          : textScale // ignore: cast_nullable_to_non_nullable
              as double,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String,
      selectedLocationId: freezed == selectedLocationId
          ? _value.selectedLocationId
          : selectedLocationId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedLocationName: freezed == selectedLocationName
          ? _value.selectedLocationName
          : selectedLocationName // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedLocationLatitude: freezed == selectedLocationLatitude
          ? _value.selectedLocationLatitude
          : selectedLocationLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      selectedLocationLongitude: freezed == selectedLocationLongitude
          ? _value.selectedLocationLongitude
          : selectedLocationLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      selectedLocationCountryCode: freezed == selectedLocationCountryCode
          ? _value.selectedLocationCountryCode
          : selectedLocationCountryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedLocationCountryName: freezed == selectedLocationCountryName
          ? _value.selectedLocationCountryName
          : selectedLocationCountryName // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledNotificationTimes: null == scheduledNotificationTimes
          ? _value.scheduledNotificationTimes
          : scheduledNotificationTimes // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPreferencesImplCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$$UserPreferencesImplCopyWith(_$UserPreferencesImpl value,
          $Res Function(_$UserPreferencesImpl) then) =
      __$$UserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String language,
      @HiveField(1) String selectedSheikhId,
      @HiveField(2) bool notificationsEnabled,
      @HiveField(3) List<String> favoriteZikrIds,
      @HiveField(4) DateTime? dndStartTime,
      @HiveField(5) DateTime? dndEndTime,
      @HiveField(6) bool dndEnabled,
      @HiveField(7) double textScale,
      @HiveField(9) String themeMode,
      @HiveField(10) int? selectedLocationId,
      @HiveField(11) String? selectedLocationName,
      @HiveField(12) double? selectedLocationLatitude,
      @HiveField(13) double? selectedLocationLongitude,
      @HiveField(14) String? selectedLocationCountryCode,
      @HiveField(15) String? selectedLocationCountryName,
      @HiveField(16) List<String> scheduledNotificationTimes});
}

/// @nodoc
class __$$UserPreferencesImplCopyWithImpl<$Res>
    extends _$UserPreferencesCopyWithImpl<$Res, _$UserPreferencesImpl>
    implements _$$UserPreferencesImplCopyWith<$Res> {
  __$$UserPreferencesImplCopyWithImpl(
      _$UserPreferencesImpl _value, $Res Function(_$UserPreferencesImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? language = null,
    Object? selectedSheikhId = null,
    Object? notificationsEnabled = null,
    Object? favoriteZikrIds = null,
    Object? dndStartTime = freezed,
    Object? dndEndTime = freezed,
    Object? dndEnabled = null,
    Object? textScale = null,
    Object? themeMode = null,
    Object? selectedLocationId = freezed,
    Object? selectedLocationName = freezed,
    Object? selectedLocationLatitude = freezed,
    Object? selectedLocationLongitude = freezed,
    Object? selectedLocationCountryCode = freezed,
    Object? selectedLocationCountryName = freezed,
    Object? scheduledNotificationTimes = null,
  }) {
    return _then(_$UserPreferencesImpl(
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      selectedSheikhId: null == selectedSheikhId
          ? _value.selectedSheikhId
          : selectedSheikhId // ignore: cast_nullable_to_non_nullable
              as String,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      favoriteZikrIds: null == favoriteZikrIds
          ? _value._favoriteZikrIds
          : favoriteZikrIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dndStartTime: freezed == dndStartTime
          ? _value.dndStartTime
          : dndStartTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dndEndTime: freezed == dndEndTime
          ? _value.dndEndTime
          : dndEndTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dndEnabled: null == dndEnabled
          ? _value.dndEnabled
          : dndEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      textScale: null == textScale
          ? _value.textScale
          : textScale // ignore: cast_nullable_to_non_nullable
              as double,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String,
      selectedLocationId: freezed == selectedLocationId
          ? _value.selectedLocationId
          : selectedLocationId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedLocationName: freezed == selectedLocationName
          ? _value.selectedLocationName
          : selectedLocationName // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedLocationLatitude: freezed == selectedLocationLatitude
          ? _value.selectedLocationLatitude
          : selectedLocationLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      selectedLocationLongitude: freezed == selectedLocationLongitude
          ? _value.selectedLocationLongitude
          : selectedLocationLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      selectedLocationCountryCode: freezed == selectedLocationCountryCode
          ? _value.selectedLocationCountryCode
          : selectedLocationCountryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedLocationCountryName: freezed == selectedLocationCountryName
          ? _value.selectedLocationCountryName
          : selectedLocationCountryName // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledNotificationTimes: null == scheduledNotificationTimes
          ? _value._scheduledNotificationTimes
          : scheduledNotificationTimes // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl(
      {@HiveField(0) this.language = 'ar',
      @HiveField(1) this.selectedSheikhId = 'sh01',
      @HiveField(2) this.notificationsEnabled = false,
      @HiveField(3) final List<String> favoriteZikrIds = const [],
      @HiveField(4) this.dndStartTime,
      @HiveField(5) this.dndEndTime,
      @HiveField(6) this.dndEnabled = false,
      @HiveField(7) this.textScale = 1.0,
      @HiveField(9) this.themeMode = 'system',
      @HiveField(10) this.selectedLocationId,
      @HiveField(11) this.selectedLocationName,
      @HiveField(12) this.selectedLocationLatitude,
      @HiveField(13) this.selectedLocationLongitude,
      @HiveField(14) this.selectedLocationCountryCode,
      @HiveField(15) this.selectedLocationCountryName,
      @HiveField(16) final List<String> scheduledNotificationTimes = const []})
      : _favoriteZikrIds = favoriteZikrIds,
        _scheduledNotificationTimes = scheduledNotificationTimes;

  factory _$UserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesImplFromJson(json);

  @override
  @JsonKey()
  @HiveField(0)
  final String language;
  @override
  @JsonKey()
  @HiveField(1)
  final String selectedSheikhId;
  @override
  @JsonKey()
  @HiveField(2)
  final bool notificationsEnabled;
  final List<String> _favoriteZikrIds;
  @override
  @JsonKey()
  @HiveField(3)
  List<String> get favoriteZikrIds {
    if (_favoriteZikrIds is EqualUnmodifiableListView) return _favoriteZikrIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteZikrIds);
  }

  @override
  @HiveField(4)
  final DateTime? dndStartTime;
  @override
  @HiveField(5)
  final DateTime? dndEndTime;
  @override
  @JsonKey()
  @HiveField(6)
  final bool dndEnabled;
  @override
  @JsonKey()
  @HiveField(7)
  final double textScale;
  @override
  @JsonKey()
  @HiveField(9)
  final String themeMode;
// 'light', 'dark', 'system'
  @override
  @HiveField(10)
  final int? selectedLocationId;
  @override
  @HiveField(11)
  final String? selectedLocationName;
  @override
  @HiveField(12)
  final double? selectedLocationLatitude;
  @override
  @HiveField(13)
  final double? selectedLocationLongitude;
  @override
  @HiveField(14)
  final String? selectedLocationCountryCode;
  @override
  @HiveField(15)
  final String? selectedLocationCountryName;
  final List<String> _scheduledNotificationTimes;
  @override
  @JsonKey()
  @HiveField(16)
  List<String> get scheduledNotificationTimes {
    if (_scheduledNotificationTimes is EqualUnmodifiableListView)
      return _scheduledNotificationTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scheduledNotificationTimes);
  }

  @override
  String toString() {
    return 'UserPreferences(language: $language, selectedSheikhId: $selectedSheikhId, notificationsEnabled: $notificationsEnabled, favoriteZikrIds: $favoriteZikrIds, dndStartTime: $dndStartTime, dndEndTime: $dndEndTime, dndEnabled: $dndEnabled, textScale: $textScale, themeMode: $themeMode, selectedLocationId: $selectedLocationId, selectedLocationName: $selectedLocationName, selectedLocationLatitude: $selectedLocationLatitude, selectedLocationLongitude: $selectedLocationLongitude, selectedLocationCountryCode: $selectedLocationCountryCode, selectedLocationCountryName: $selectedLocationCountryName, scheduledNotificationTimes: $scheduledNotificationTimes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesImpl &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.selectedSheikhId, selectedSheikhId) ||
                other.selectedSheikhId == selectedSheikhId) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            const DeepCollectionEquality()
                .equals(other._favoriteZikrIds, _favoriteZikrIds) &&
            (identical(other.dndStartTime, dndStartTime) ||
                other.dndStartTime == dndStartTime) &&
            (identical(other.dndEndTime, dndEndTime) ||
                other.dndEndTime == dndEndTime) &&
            (identical(other.dndEnabled, dndEnabled) ||
                other.dndEnabled == dndEnabled) &&
            (identical(other.textScale, textScale) ||
                other.textScale == textScale) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.selectedLocationId, selectedLocationId) ||
                other.selectedLocationId == selectedLocationId) &&
            (identical(other.selectedLocationName, selectedLocationName) ||
                other.selectedLocationName == selectedLocationName) &&
            (identical(
                    other.selectedLocationLatitude, selectedLocationLatitude) ||
                other.selectedLocationLatitude == selectedLocationLatitude) &&
            (identical(other.selectedLocationLongitude,
                    selectedLocationLongitude) ||
                other.selectedLocationLongitude == selectedLocationLongitude) &&
            (identical(other.selectedLocationCountryCode,
                    selectedLocationCountryCode) ||
                other.selectedLocationCountryCode ==
                    selectedLocationCountryCode) &&
            (identical(other.selectedLocationCountryName,
                    selectedLocationCountryName) ||
                other.selectedLocationCountryName ==
                    selectedLocationCountryName) &&
            const DeepCollectionEquality().equals(
                other._scheduledNotificationTimes,
                _scheduledNotificationTimes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      language,
      selectedSheikhId,
      notificationsEnabled,
      const DeepCollectionEquality().hash(_favoriteZikrIds),
      dndStartTime,
      dndEndTime,
      dndEnabled,
      textScale,
      themeMode,
      selectedLocationId,
      selectedLocationName,
      selectedLocationLatitude,
      selectedLocationLongitude,
      selectedLocationCountryCode,
      selectedLocationCountryName,
      const DeepCollectionEquality().hash(_scheduledNotificationTimes));

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      __$$UserPreferencesImplCopyWithImpl<_$UserPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesImplToJson(
      this,
    );
  }
}

abstract class _UserPreferences implements UserPreferences {
  const factory _UserPreferences(
          {@HiveField(0) final String language,
          @HiveField(1) final String selectedSheikhId,
          @HiveField(2) final bool notificationsEnabled,
          @HiveField(3) final List<String> favoriteZikrIds,
          @HiveField(4) final DateTime? dndStartTime,
          @HiveField(5) final DateTime? dndEndTime,
          @HiveField(6) final bool dndEnabled,
          @HiveField(7) final double textScale,
          @HiveField(9) final String themeMode,
          @HiveField(10) final int? selectedLocationId,
          @HiveField(11) final String? selectedLocationName,
          @HiveField(12) final double? selectedLocationLatitude,
          @HiveField(13) final double? selectedLocationLongitude,
          @HiveField(14) final String? selectedLocationCountryCode,
          @HiveField(15) final String? selectedLocationCountryName,
          @HiveField(16) final List<String> scheduledNotificationTimes}) =
      _$UserPreferencesImpl;

  factory _UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesImpl.fromJson;

  @override
  @HiveField(0)
  String get language;
  @override
  @HiveField(1)
  String get selectedSheikhId;
  @override
  @HiveField(2)
  bool get notificationsEnabled;
  @override
  @HiveField(3)
  List<String> get favoriteZikrIds;
  @override
  @HiveField(4)
  DateTime? get dndStartTime;
  @override
  @HiveField(5)
  DateTime? get dndEndTime;
  @override
  @HiveField(6)
  bool get dndEnabled;
  @override
  @HiveField(7)
  double get textScale;
  @override
  @HiveField(9)
  String get themeMode; // 'light', 'dark', 'system'
  @override
  @HiveField(10)
  int? get selectedLocationId;
  @override
  @HiveField(11)
  String? get selectedLocationName;
  @override
  @HiveField(12)
  double? get selectedLocationLatitude;
  @override
  @HiveField(13)
  double? get selectedLocationLongitude;
  @override
  @HiveField(14)
  String? get selectedLocationCountryCode;
  @override
  @HiveField(15)
  String? get selectedLocationCountryName;
  @override
  @HiveField(16)
  List<String> get scheduledNotificationTimes;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
