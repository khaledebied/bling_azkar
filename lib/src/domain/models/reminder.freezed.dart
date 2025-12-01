// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Reminder _$ReminderFromJson(Map<String, dynamic> json) {
  return _Reminder.fromJson(json);
}

/// @nodoc
mixin _$Reminder {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get zikrId => throw _privateConstructorUsedError;
  @HiveField(2)
  String get title => throw _privateConstructorUsedError;
  @HiveField(3)
  bool get isActive => throw _privateConstructorUsedError;
  @HiveField(4)
  ReminderType get type => throw _privateConstructorUsedError;
  @HiveField(5)
  DateTime? get fixedTime => throw _privateConstructorUsedError;
  @HiveField(6)
  int? get intervalMinutes => throw _privateConstructorUsedError;
  @HiveField(7)
  DateTime? get lastScheduledTime => throw _privateConstructorUsedError;
  @HiveField(8)
  int? get notificationId => throw _privateConstructorUsedError;
  @HiveField(9)
  String get sheikhId => throw _privateConstructorUsedError;

  /// Serializes this Reminder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReminderCopyWith<Reminder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReminderCopyWith<$Res> {
  factory $ReminderCopyWith(Reminder value, $Res Function(Reminder) then) =
      _$ReminderCopyWithImpl<$Res, Reminder>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String zikrId,
      @HiveField(2) String title,
      @HiveField(3) bool isActive,
      @HiveField(4) ReminderType type,
      @HiveField(5) DateTime? fixedTime,
      @HiveField(6) int? intervalMinutes,
      @HiveField(7) DateTime? lastScheduledTime,
      @HiveField(8) int? notificationId,
      @HiveField(9) String sheikhId});
}

/// @nodoc
class _$ReminderCopyWithImpl<$Res, $Val extends Reminder>
    implements $ReminderCopyWith<$Res> {
  _$ReminderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? zikrId = null,
    Object? title = null,
    Object? isActive = null,
    Object? type = null,
    Object? fixedTime = freezed,
    Object? intervalMinutes = freezed,
    Object? lastScheduledTime = freezed,
    Object? notificationId = freezed,
    Object? sheikhId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      zikrId: null == zikrId
          ? _value.zikrId
          : zikrId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReminderType,
      fixedTime: freezed == fixedTime
          ? _value.fixedTime
          : fixedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      intervalMinutes: freezed == intervalMinutes
          ? _value.intervalMinutes
          : intervalMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      lastScheduledTime: freezed == lastScheduledTime
          ? _value.lastScheduledTime
          : lastScheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notificationId: freezed == notificationId
          ? _value.notificationId
          : notificationId // ignore: cast_nullable_to_non_nullable
              as int?,
      sheikhId: null == sheikhId
          ? _value.sheikhId
          : sheikhId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReminderImplCopyWith<$Res>
    implements $ReminderCopyWith<$Res> {
  factory _$$ReminderImplCopyWith(
          _$ReminderImpl value, $Res Function(_$ReminderImpl) then) =
      __$$ReminderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String zikrId,
      @HiveField(2) String title,
      @HiveField(3) bool isActive,
      @HiveField(4) ReminderType type,
      @HiveField(5) DateTime? fixedTime,
      @HiveField(6) int? intervalMinutes,
      @HiveField(7) DateTime? lastScheduledTime,
      @HiveField(8) int? notificationId,
      @HiveField(9) String sheikhId});
}

/// @nodoc
class __$$ReminderImplCopyWithImpl<$Res>
    extends _$ReminderCopyWithImpl<$Res, _$ReminderImpl>
    implements _$$ReminderImplCopyWith<$Res> {
  __$$ReminderImplCopyWithImpl(
      _$ReminderImpl _value, $Res Function(_$ReminderImpl) _then)
      : super(_value, _then);

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? zikrId = null,
    Object? title = null,
    Object? isActive = null,
    Object? type = null,
    Object? fixedTime = freezed,
    Object? intervalMinutes = freezed,
    Object? lastScheduledTime = freezed,
    Object? notificationId = freezed,
    Object? sheikhId = null,
  }) {
    return _then(_$ReminderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      zikrId: null == zikrId
          ? _value.zikrId
          : zikrId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReminderType,
      fixedTime: freezed == fixedTime
          ? _value.fixedTime
          : fixedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      intervalMinutes: freezed == intervalMinutes
          ? _value.intervalMinutes
          : intervalMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      lastScheduledTime: freezed == lastScheduledTime
          ? _value.lastScheduledTime
          : lastScheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notificationId: freezed == notificationId
          ? _value.notificationId
          : notificationId // ignore: cast_nullable_to_non_nullable
              as int?,
      sheikhId: null == sheikhId
          ? _value.sheikhId
          : sheikhId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReminderImpl implements _Reminder {
  const _$ReminderImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.zikrId,
      @HiveField(2) required this.title,
      @HiveField(3) required this.isActive,
      @HiveField(4) required this.type,
      @HiveField(5) required this.fixedTime,
      @HiveField(6) required this.intervalMinutes,
      @HiveField(7) required this.lastScheduledTime,
      @HiveField(8) required this.notificationId,
      @HiveField(9) required this.sheikhId});

  factory _$ReminderImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReminderImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String zikrId;
  @override
  @HiveField(2)
  final String title;
  @override
  @HiveField(3)
  final bool isActive;
  @override
  @HiveField(4)
  final ReminderType type;
  @override
  @HiveField(5)
  final DateTime? fixedTime;
  @override
  @HiveField(6)
  final int? intervalMinutes;
  @override
  @HiveField(7)
  final DateTime? lastScheduledTime;
  @override
  @HiveField(8)
  final int? notificationId;
  @override
  @HiveField(9)
  final String sheikhId;

  @override
  String toString() {
    return 'Reminder(id: $id, zikrId: $zikrId, title: $title, isActive: $isActive, type: $type, fixedTime: $fixedTime, intervalMinutes: $intervalMinutes, lastScheduledTime: $lastScheduledTime, notificationId: $notificationId, sheikhId: $sheikhId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReminderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.zikrId, zikrId) || other.zikrId == zikrId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.fixedTime, fixedTime) ||
                other.fixedTime == fixedTime) &&
            (identical(other.intervalMinutes, intervalMinutes) ||
                other.intervalMinutes == intervalMinutes) &&
            (identical(other.lastScheduledTime, lastScheduledTime) ||
                other.lastScheduledTime == lastScheduledTime) &&
            (identical(other.notificationId, notificationId) ||
                other.notificationId == notificationId) &&
            (identical(other.sheikhId, sheikhId) ||
                other.sheikhId == sheikhId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      zikrId,
      title,
      isActive,
      type,
      fixedTime,
      intervalMinutes,
      lastScheduledTime,
      notificationId,
      sheikhId);

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReminderImplCopyWith<_$ReminderImpl> get copyWith =>
      __$$ReminderImplCopyWithImpl<_$ReminderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReminderImplToJson(
      this,
    );
  }
}

abstract class _Reminder implements Reminder {
  const factory _Reminder(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String zikrId,
      @HiveField(2) required final String title,
      @HiveField(3) required final bool isActive,
      @HiveField(4) required final ReminderType type,
      @HiveField(5) required final DateTime? fixedTime,
      @HiveField(6) required final int? intervalMinutes,
      @HiveField(7) required final DateTime? lastScheduledTime,
      @HiveField(8) required final int? notificationId,
      @HiveField(9) required final String sheikhId}) = _$ReminderImpl;

  factory _Reminder.fromJson(Map<String, dynamic> json) =
      _$ReminderImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get zikrId;
  @override
  @HiveField(2)
  String get title;
  @override
  @HiveField(3)
  bool get isActive;
  @override
  @HiveField(4)
  ReminderType get type;
  @override
  @HiveField(5)
  DateTime? get fixedTime;
  @override
  @HiveField(6)
  int? get intervalMinutes;
  @override
  @HiveField(7)
  DateTime? get lastScheduledTime;
  @override
  @HiveField(8)
  int? get notificationId;
  @override
  @HiveField(9)
  String get sheikhId;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReminderImplCopyWith<_$ReminderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
