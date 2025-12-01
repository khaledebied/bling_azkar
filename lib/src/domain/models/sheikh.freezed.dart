// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sheikh.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Sheikh _$SheikhFromJson(Map<String, dynamic> json) {
  return _Sheikh.fromJson(json);
}

/// @nodoc
mixin _$Sheikh {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get name => throw _privateConstructorUsedError;
  @HiveField(2)
  String get nameAr => throw _privateConstructorUsedError;
  @HiveField(3)
  String get bio => throw _privateConstructorUsedError;
  @HiveField(4)
  String get imageUrl => throw _privateConstructorUsedError;
  @HiveField(5)
  bool get isDownloaded => throw _privateConstructorUsedError;
  @HiveField(6)
  List<String> get downloadedAudioIds => throw _privateConstructorUsedError;

  /// Serializes this Sheikh to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Sheikh
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SheikhCopyWith<Sheikh> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SheikhCopyWith<$Res> {
  factory $SheikhCopyWith(Sheikh value, $Res Function(Sheikh) then) =
      _$SheikhCopyWithImpl<$Res, Sheikh>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) String nameAr,
      @HiveField(3) String bio,
      @HiveField(4) String imageUrl,
      @HiveField(5) bool isDownloaded,
      @HiveField(6) List<String> downloadedAudioIds});
}

/// @nodoc
class _$SheikhCopyWithImpl<$Res, $Val extends Sheikh>
    implements $SheikhCopyWith<$Res> {
  _$SheikhCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Sheikh
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameAr = null,
    Object? bio = null,
    Object? imageUrl = null,
    Object? isDownloaded = null,
    Object? downloadedAudioIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: null == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isDownloaded: null == isDownloaded
          ? _value.isDownloaded
          : isDownloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      downloadedAudioIds: null == downloadedAudioIds
          ? _value.downloadedAudioIds
          : downloadedAudioIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SheikhImplCopyWith<$Res> implements $SheikhCopyWith<$Res> {
  factory _$$SheikhImplCopyWith(
          _$SheikhImpl value, $Res Function(_$SheikhImpl) then) =
      __$$SheikhImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) String nameAr,
      @HiveField(3) String bio,
      @HiveField(4) String imageUrl,
      @HiveField(5) bool isDownloaded,
      @HiveField(6) List<String> downloadedAudioIds});
}

/// @nodoc
class __$$SheikhImplCopyWithImpl<$Res>
    extends _$SheikhCopyWithImpl<$Res, _$SheikhImpl>
    implements _$$SheikhImplCopyWith<$Res> {
  __$$SheikhImplCopyWithImpl(
      _$SheikhImpl _value, $Res Function(_$SheikhImpl) _then)
      : super(_value, _then);

  /// Create a copy of Sheikh
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameAr = null,
    Object? bio = null,
    Object? imageUrl = null,
    Object? isDownloaded = null,
    Object? downloadedAudioIds = null,
  }) {
    return _then(_$SheikhImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: null == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isDownloaded: null == isDownloaded
          ? _value.isDownloaded
          : isDownloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      downloadedAudioIds: null == downloadedAudioIds
          ? _value._downloadedAudioIds
          : downloadedAudioIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SheikhImpl implements _Sheikh {
  const _$SheikhImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.name,
      @HiveField(2) required this.nameAr,
      @HiveField(3) required this.bio,
      @HiveField(4) required this.imageUrl,
      @HiveField(5) this.isDownloaded = false,
      @HiveField(6) final List<String> downloadedAudioIds = const []})
      : _downloadedAudioIds = downloadedAudioIds;

  factory _$SheikhImpl.fromJson(Map<String, dynamic> json) =>
      _$$SheikhImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String nameAr;
  @override
  @HiveField(3)
  final String bio;
  @override
  @HiveField(4)
  final String imageUrl;
  @override
  @JsonKey()
  @HiveField(5)
  final bool isDownloaded;
  final List<String> _downloadedAudioIds;
  @override
  @JsonKey()
  @HiveField(6)
  List<String> get downloadedAudioIds {
    if (_downloadedAudioIds is EqualUnmodifiableListView)
      return _downloadedAudioIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_downloadedAudioIds);
  }

  @override
  String toString() {
    return 'Sheikh(id: $id, name: $name, nameAr: $nameAr, bio: $bio, imageUrl: $imageUrl, isDownloaded: $isDownloaded, downloadedAudioIds: $downloadedAudioIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SheikhImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isDownloaded, isDownloaded) ||
                other.isDownloaded == isDownloaded) &&
            const DeepCollectionEquality()
                .equals(other._downloadedAudioIds, _downloadedAudioIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, nameAr, bio, imageUrl,
      isDownloaded, const DeepCollectionEquality().hash(_downloadedAudioIds));

  /// Create a copy of Sheikh
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SheikhImplCopyWith<_$SheikhImpl> get copyWith =>
      __$$SheikhImplCopyWithImpl<_$SheikhImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SheikhImplToJson(
      this,
    );
  }
}

abstract class _Sheikh implements Sheikh {
  const factory _Sheikh(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String name,
      @HiveField(2) required final String nameAr,
      @HiveField(3) required final String bio,
      @HiveField(4) required final String imageUrl,
      @HiveField(5) final bool isDownloaded,
      @HiveField(6) final List<String> downloadedAudioIds}) = _$SheikhImpl;

  factory _Sheikh.fromJson(Map<String, dynamic> json) = _$SheikhImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get name;
  @override
  @HiveField(2)
  String get nameAr;
  @override
  @HiveField(3)
  String get bio;
  @override
  @HiveField(4)
  String get imageUrl;
  @override
  @HiveField(5)
  bool get isDownloaded;
  @override
  @HiveField(6)
  List<String> get downloadedAudioIds;

  /// Create a copy of Sheikh
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SheikhImplCopyWith<_$SheikhImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DownloadedAudio _$DownloadedAudioFromJson(Map<String, dynamic> json) {
  return _DownloadedAudio.fromJson(json);
}

/// @nodoc
mixin _$DownloadedAudio {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get zikrId => throw _privateConstructorUsedError;
  @HiveField(2)
  String get sheikhId => throw _privateConstructorUsedError;
  @HiveField(3)
  String get localPath => throw _privateConstructorUsedError;
  @HiveField(4)
  int get fileSizeBytes => throw _privateConstructorUsedError;
  @HiveField(5)
  DateTime get downloadedAt => throw _privateConstructorUsedError;

  /// Serializes this DownloadedAudio to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DownloadedAudio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadedAudioCopyWith<DownloadedAudio> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadedAudioCopyWith<$Res> {
  factory $DownloadedAudioCopyWith(
          DownloadedAudio value, $Res Function(DownloadedAudio) then) =
      _$DownloadedAudioCopyWithImpl<$Res, DownloadedAudio>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String zikrId,
      @HiveField(2) String sheikhId,
      @HiveField(3) String localPath,
      @HiveField(4) int fileSizeBytes,
      @HiveField(5) DateTime downloadedAt});
}

/// @nodoc
class _$DownloadedAudioCopyWithImpl<$Res, $Val extends DownloadedAudio>
    implements $DownloadedAudioCopyWith<$Res> {
  _$DownloadedAudioCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadedAudio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? zikrId = null,
    Object? sheikhId = null,
    Object? localPath = null,
    Object? fileSizeBytes = null,
    Object? downloadedAt = null,
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
      sheikhId: null == sheikhId
          ? _value.sheikhId
          : sheikhId // ignore: cast_nullable_to_non_nullable
              as String,
      localPath: null == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSizeBytes: null == fileSizeBytes
          ? _value.fileSizeBytes
          : fileSizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      downloadedAt: null == downloadedAt
          ? _value.downloadedAt
          : downloadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DownloadedAudioImplCopyWith<$Res>
    implements $DownloadedAudioCopyWith<$Res> {
  factory _$$DownloadedAudioImplCopyWith(_$DownloadedAudioImpl value,
          $Res Function(_$DownloadedAudioImpl) then) =
      __$$DownloadedAudioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String zikrId,
      @HiveField(2) String sheikhId,
      @HiveField(3) String localPath,
      @HiveField(4) int fileSizeBytes,
      @HiveField(5) DateTime downloadedAt});
}

/// @nodoc
class __$$DownloadedAudioImplCopyWithImpl<$Res>
    extends _$DownloadedAudioCopyWithImpl<$Res, _$DownloadedAudioImpl>
    implements _$$DownloadedAudioImplCopyWith<$Res> {
  __$$DownloadedAudioImplCopyWithImpl(
      _$DownloadedAudioImpl _value, $Res Function(_$DownloadedAudioImpl) _then)
      : super(_value, _then);

  /// Create a copy of DownloadedAudio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? zikrId = null,
    Object? sheikhId = null,
    Object? localPath = null,
    Object? fileSizeBytes = null,
    Object? downloadedAt = null,
  }) {
    return _then(_$DownloadedAudioImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      zikrId: null == zikrId
          ? _value.zikrId
          : zikrId // ignore: cast_nullable_to_non_nullable
              as String,
      sheikhId: null == sheikhId
          ? _value.sheikhId
          : sheikhId // ignore: cast_nullable_to_non_nullable
              as String,
      localPath: null == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSizeBytes: null == fileSizeBytes
          ? _value.fileSizeBytes
          : fileSizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      downloadedAt: null == downloadedAt
          ? _value.downloadedAt
          : downloadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DownloadedAudioImpl implements _DownloadedAudio {
  const _$DownloadedAudioImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.zikrId,
      @HiveField(2) required this.sheikhId,
      @HiveField(3) required this.localPath,
      @HiveField(4) required this.fileSizeBytes,
      @HiveField(5) required this.downloadedAt});

  factory _$DownloadedAudioImpl.fromJson(Map<String, dynamic> json) =>
      _$$DownloadedAudioImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String zikrId;
  @override
  @HiveField(2)
  final String sheikhId;
  @override
  @HiveField(3)
  final String localPath;
  @override
  @HiveField(4)
  final int fileSizeBytes;
  @override
  @HiveField(5)
  final DateTime downloadedAt;

  @override
  String toString() {
    return 'DownloadedAudio(id: $id, zikrId: $zikrId, sheikhId: $sheikhId, localPath: $localPath, fileSizeBytes: $fileSizeBytes, downloadedAt: $downloadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadedAudioImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.zikrId, zikrId) || other.zikrId == zikrId) &&
            (identical(other.sheikhId, sheikhId) ||
                other.sheikhId == sheikhId) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.downloadedAt, downloadedAt) ||
                other.downloadedAt == downloadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, zikrId, sheikhId, localPath,
      fileSizeBytes, downloadedAt);

  /// Create a copy of DownloadedAudio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadedAudioImplCopyWith<_$DownloadedAudioImpl> get copyWith =>
      __$$DownloadedAudioImplCopyWithImpl<_$DownloadedAudioImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DownloadedAudioImplToJson(
      this,
    );
  }
}

abstract class _DownloadedAudio implements DownloadedAudio {
  const factory _DownloadedAudio(
          {@HiveField(0) required final String id,
          @HiveField(1) required final String zikrId,
          @HiveField(2) required final String sheikhId,
          @HiveField(3) required final String localPath,
          @HiveField(4) required final int fileSizeBytes,
          @HiveField(5) required final DateTime downloadedAt}) =
      _$DownloadedAudioImpl;

  factory _DownloadedAudio.fromJson(Map<String, dynamic> json) =
      _$DownloadedAudioImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get zikrId;
  @override
  @HiveField(2)
  String get sheikhId;
  @override
  @HiveField(3)
  String get localPath;
  @override
  @HiveField(4)
  int get fileSizeBytes;
  @override
  @HiveField(5)
  DateTime get downloadedAt;

  /// Create a copy of DownloadedAudio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadedAudioImplCopyWith<_$DownloadedAudioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
