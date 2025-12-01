// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zikr.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Zikr _$ZikrFromJson(Map<String, dynamic> json) {
  return _Zikr.fromJson(json);
}

/// @nodoc
mixin _$Zikr {
  String get id => throw _privateConstructorUsedError;
  LocalizedText get title => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  LocalizedText get translation => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get defaultCount => throw _privateConstructorUsedError;
  List<AudioInfo> get audio => throw _privateConstructorUsedError;

  /// Serializes this Zikr to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Zikr
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ZikrCopyWith<Zikr> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ZikrCopyWith<$Res> {
  factory $ZikrCopyWith(Zikr value, $Res Function(Zikr) then) =
      _$ZikrCopyWithImpl<$Res, Zikr>;
  @useResult
  $Res call(
      {String id,
      LocalizedText title,
      String text,
      LocalizedText translation,
      String category,
      int defaultCount,
      List<AudioInfo> audio});

  $LocalizedTextCopyWith<$Res> get title;
  $LocalizedTextCopyWith<$Res> get translation;
}

/// @nodoc
class _$ZikrCopyWithImpl<$Res, $Val extends Zikr>
    implements $ZikrCopyWith<$Res> {
  _$ZikrCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Zikr
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? text = null,
    Object? translation = null,
    Object? category = null,
    Object? defaultCount = null,
    Object? audio = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as LocalizedText,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      translation: null == translation
          ? _value.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as LocalizedText,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      defaultCount: null == defaultCount
          ? _value.defaultCount
          : defaultCount // ignore: cast_nullable_to_non_nullable
              as int,
      audio: null == audio
          ? _value.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as List<AudioInfo>,
    ) as $Val);
  }

  /// Create a copy of Zikr
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocalizedTextCopyWith<$Res> get title {
    return $LocalizedTextCopyWith<$Res>(_value.title, (value) {
      return _then(_value.copyWith(title: value) as $Val);
    });
  }

  /// Create a copy of Zikr
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocalizedTextCopyWith<$Res> get translation {
    return $LocalizedTextCopyWith<$Res>(_value.translation, (value) {
      return _then(_value.copyWith(translation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ZikrImplCopyWith<$Res> implements $ZikrCopyWith<$Res> {
  factory _$$ZikrImplCopyWith(
          _$ZikrImpl value, $Res Function(_$ZikrImpl) then) =
      __$$ZikrImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      LocalizedText title,
      String text,
      LocalizedText translation,
      String category,
      int defaultCount,
      List<AudioInfo> audio});

  @override
  $LocalizedTextCopyWith<$Res> get title;
  @override
  $LocalizedTextCopyWith<$Res> get translation;
}

/// @nodoc
class __$$ZikrImplCopyWithImpl<$Res>
    extends _$ZikrCopyWithImpl<$Res, _$ZikrImpl>
    implements _$$ZikrImplCopyWith<$Res> {
  __$$ZikrImplCopyWithImpl(_$ZikrImpl _value, $Res Function(_$ZikrImpl) _then)
      : super(_value, _then);

  /// Create a copy of Zikr
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? text = null,
    Object? translation = null,
    Object? category = null,
    Object? defaultCount = null,
    Object? audio = null,
  }) {
    return _then(_$ZikrImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as LocalizedText,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      translation: null == translation
          ? _value.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as LocalizedText,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      defaultCount: null == defaultCount
          ? _value.defaultCount
          : defaultCount // ignore: cast_nullable_to_non_nullable
              as int,
      audio: null == audio
          ? _value._audio
          : audio // ignore: cast_nullable_to_non_nullable
              as List<AudioInfo>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ZikrImpl implements _Zikr {
  const _$ZikrImpl(
      {required this.id,
      required this.title,
      required this.text,
      required this.translation,
      required this.category,
      required this.defaultCount,
      required final List<AudioInfo> audio})
      : _audio = audio;

  factory _$ZikrImpl.fromJson(Map<String, dynamic> json) =>
      _$$ZikrImplFromJson(json);

  @override
  final String id;
  @override
  final LocalizedText title;
  @override
  final String text;
  @override
  final LocalizedText translation;
  @override
  final String category;
  @override
  final int defaultCount;
  final List<AudioInfo> _audio;
  @override
  List<AudioInfo> get audio {
    if (_audio is EqualUnmodifiableListView) return _audio;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_audio);
  }

  @override
  String toString() {
    return 'Zikr(id: $id, title: $title, text: $text, translation: $translation, category: $category, defaultCount: $defaultCount, audio: $audio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ZikrImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.translation, translation) ||
                other.translation == translation) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.defaultCount, defaultCount) ||
                other.defaultCount == defaultCount) &&
            const DeepCollectionEquality().equals(other._audio, _audio));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, text, translation,
      category, defaultCount, const DeepCollectionEquality().hash(_audio));

  /// Create a copy of Zikr
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ZikrImplCopyWith<_$ZikrImpl> get copyWith =>
      __$$ZikrImplCopyWithImpl<_$ZikrImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ZikrImplToJson(
      this,
    );
  }
}

abstract class _Zikr implements Zikr {
  const factory _Zikr(
      {required final String id,
      required final LocalizedText title,
      required final String text,
      required final LocalizedText translation,
      required final String category,
      required final int defaultCount,
      required final List<AudioInfo> audio}) = _$ZikrImpl;

  factory _Zikr.fromJson(Map<String, dynamic> json) = _$ZikrImpl.fromJson;

  @override
  String get id;
  @override
  LocalizedText get title;
  @override
  String get text;
  @override
  LocalizedText get translation;
  @override
  String get category;
  @override
  int get defaultCount;
  @override
  List<AudioInfo> get audio;

  /// Create a copy of Zikr
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ZikrImplCopyWith<_$ZikrImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LocalizedText _$LocalizedTextFromJson(Map<String, dynamic> json) {
  return _LocalizedText.fromJson(json);
}

/// @nodoc
mixin _$LocalizedText {
  String get en => throw _privateConstructorUsedError;
  String get ar => throw _privateConstructorUsedError;

  /// Serializes this LocalizedText to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocalizedText
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocalizedTextCopyWith<LocalizedText> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalizedTextCopyWith<$Res> {
  factory $LocalizedTextCopyWith(
          LocalizedText value, $Res Function(LocalizedText) then) =
      _$LocalizedTextCopyWithImpl<$Res, LocalizedText>;
  @useResult
  $Res call({String en, String ar});
}

/// @nodoc
class _$LocalizedTextCopyWithImpl<$Res, $Val extends LocalizedText>
    implements $LocalizedTextCopyWith<$Res> {
  _$LocalizedTextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocalizedText
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? en = null,
    Object? ar = null,
  }) {
    return _then(_value.copyWith(
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
      ar: null == ar
          ? _value.ar
          : ar // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocalizedTextImplCopyWith<$Res>
    implements $LocalizedTextCopyWith<$Res> {
  factory _$$LocalizedTextImplCopyWith(
          _$LocalizedTextImpl value, $Res Function(_$LocalizedTextImpl) then) =
      __$$LocalizedTextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String en, String ar});
}

/// @nodoc
class __$$LocalizedTextImplCopyWithImpl<$Res>
    extends _$LocalizedTextCopyWithImpl<$Res, _$LocalizedTextImpl>
    implements _$$LocalizedTextImplCopyWith<$Res> {
  __$$LocalizedTextImplCopyWithImpl(
      _$LocalizedTextImpl _value, $Res Function(_$LocalizedTextImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocalizedText
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? en = null,
    Object? ar = null,
  }) {
    return _then(_$LocalizedTextImpl(
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
      ar: null == ar
          ? _value.ar
          : ar // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalizedTextImpl implements _LocalizedText {
  const _$LocalizedTextImpl({required this.en, required this.ar});

  factory _$LocalizedTextImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalizedTextImplFromJson(json);

  @override
  final String en;
  @override
  final String ar;

  @override
  String toString() {
    return 'LocalizedText(en: $en, ar: $ar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalizedTextImpl &&
            (identical(other.en, en) || other.en == en) &&
            (identical(other.ar, ar) || other.ar == ar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, en, ar);

  /// Create a copy of LocalizedText
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalizedTextImplCopyWith<_$LocalizedTextImpl> get copyWith =>
      __$$LocalizedTextImplCopyWithImpl<_$LocalizedTextImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalizedTextImplToJson(
      this,
    );
  }
}

abstract class _LocalizedText implements LocalizedText {
  const factory _LocalizedText(
      {required final String en,
      required final String ar}) = _$LocalizedTextImpl;

  factory _LocalizedText.fromJson(Map<String, dynamic> json) =
      _$LocalizedTextImpl.fromJson;

  @override
  String get en;
  @override
  String get ar;

  /// Create a copy of LocalizedText
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocalizedTextImplCopyWith<_$LocalizedTextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AudioInfo _$AudioInfoFromJson(Map<String, dynamic> json) {
  return _AudioInfo.fromJson(json);
}

/// @nodoc
mixin _$AudioInfo {
  String get sheikhId => throw _privateConstructorUsedError;
  String get shortFile => throw _privateConstructorUsedError;
  String get fullFileUrl => throw _privateConstructorUsedError;

  /// Serializes this AudioInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AudioInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioInfoCopyWith<AudioInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioInfoCopyWith<$Res> {
  factory $AudioInfoCopyWith(AudioInfo value, $Res Function(AudioInfo) then) =
      _$AudioInfoCopyWithImpl<$Res, AudioInfo>;
  @useResult
  $Res call({String sheikhId, String shortFile, String fullFileUrl});
}

/// @nodoc
class _$AudioInfoCopyWithImpl<$Res, $Val extends AudioInfo>
    implements $AudioInfoCopyWith<$Res> {
  _$AudioInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AudioInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sheikhId = null,
    Object? shortFile = null,
    Object? fullFileUrl = null,
  }) {
    return _then(_value.copyWith(
      sheikhId: null == sheikhId
          ? _value.sheikhId
          : sheikhId // ignore: cast_nullable_to_non_nullable
              as String,
      shortFile: null == shortFile
          ? _value.shortFile
          : shortFile // ignore: cast_nullable_to_non_nullable
              as String,
      fullFileUrl: null == fullFileUrl
          ? _value.fullFileUrl
          : fullFileUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AudioInfoImplCopyWith<$Res>
    implements $AudioInfoCopyWith<$Res> {
  factory _$$AudioInfoImplCopyWith(
          _$AudioInfoImpl value, $Res Function(_$AudioInfoImpl) then) =
      __$$AudioInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sheikhId, String shortFile, String fullFileUrl});
}

/// @nodoc
class __$$AudioInfoImplCopyWithImpl<$Res>
    extends _$AudioInfoCopyWithImpl<$Res, _$AudioInfoImpl>
    implements _$$AudioInfoImplCopyWith<$Res> {
  __$$AudioInfoImplCopyWithImpl(
      _$AudioInfoImpl _value, $Res Function(_$AudioInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of AudioInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sheikhId = null,
    Object? shortFile = null,
    Object? fullFileUrl = null,
  }) {
    return _then(_$AudioInfoImpl(
      sheikhId: null == sheikhId
          ? _value.sheikhId
          : sheikhId // ignore: cast_nullable_to_non_nullable
              as String,
      shortFile: null == shortFile
          ? _value.shortFile
          : shortFile // ignore: cast_nullable_to_non_nullable
              as String,
      fullFileUrl: null == fullFileUrl
          ? _value.fullFileUrl
          : fullFileUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AudioInfoImpl implements _AudioInfo {
  const _$AudioInfoImpl(
      {required this.sheikhId,
      required this.shortFile,
      required this.fullFileUrl});

  factory _$AudioInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AudioInfoImplFromJson(json);

  @override
  final String sheikhId;
  @override
  final String shortFile;
  @override
  final String fullFileUrl;

  @override
  String toString() {
    return 'AudioInfo(sheikhId: $sheikhId, shortFile: $shortFile, fullFileUrl: $fullFileUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioInfoImpl &&
            (identical(other.sheikhId, sheikhId) ||
                other.sheikhId == sheikhId) &&
            (identical(other.shortFile, shortFile) ||
                other.shortFile == shortFile) &&
            (identical(other.fullFileUrl, fullFileUrl) ||
                other.fullFileUrl == fullFileUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, sheikhId, shortFile, fullFileUrl);

  /// Create a copy of AudioInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioInfoImplCopyWith<_$AudioInfoImpl> get copyWith =>
      __$$AudioInfoImplCopyWithImpl<_$AudioInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AudioInfoImplToJson(
      this,
    );
  }
}

abstract class _AudioInfo implements AudioInfo {
  const factory _AudioInfo(
      {required final String sheikhId,
      required final String shortFile,
      required final String fullFileUrl}) = _$AudioInfoImpl;

  factory _AudioInfo.fromJson(Map<String, dynamic> json) =
      _$AudioInfoImpl.fromJson;

  @override
  String get sheikhId;
  @override
  String get shortFile;
  @override
  String get fullFileUrl;

  /// Create a copy of AudioInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioInfoImplCopyWith<_$AudioInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
