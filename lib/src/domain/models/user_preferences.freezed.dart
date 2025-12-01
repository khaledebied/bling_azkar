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
  String get themeMode => throw _privateConstructorUsedError;

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
      @HiveField(9) String themeMode});
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
      @HiveField(9) String themeMode});
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl(
      {@HiveField(0) this.language = 'en',
      @HiveField(1) this.selectedSheikhId = 'sh01',
      @HiveField(2) this.notificationsEnabled = false,
      @HiveField(3) final List<String> favoriteZikrIds = const [],
      @HiveField(4) this.dndStartTime,
      @HiveField(5) this.dndEndTime,
      @HiveField(6) this.dndEnabled = false,
      @HiveField(7) this.textScale = 1.0,
      @HiveField(9) this.themeMode = 'system'})
      : _favoriteZikrIds = favoriteZikrIds;

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

  @override
  String toString() {
    return 'UserPreferences(language: $language, selectedSheikhId: $selectedSheikhId, notificationsEnabled: $notificationsEnabled, favoriteZikrIds: $favoriteZikrIds, dndStartTime: $dndStartTime, dndEndTime: $dndEndTime, dndEnabled: $dndEnabled, textScale: $textScale, themeMode: $themeMode)';
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
                other.themeMode == themeMode));
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
      themeMode);

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
      @HiveField(9) final String themeMode}) = _$UserPreferencesImpl;

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
  String get themeMode;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
