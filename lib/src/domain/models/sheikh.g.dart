// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheikh.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SheikhImpl _$$SheikhImplFromJson(Map<String, dynamic> json) => _$SheikhImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      bio: json['bio'] as String,
      imageUrl: json['imageUrl'] as String,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      downloadedAudioIds: (json['downloadedAudioIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SheikhImplToJson(_$SheikhImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'bio': instance.bio,
      'imageUrl': instance.imageUrl,
      'isDownloaded': instance.isDownloaded,
      'downloadedAudioIds': instance.downloadedAudioIds,
    };

_$DownloadedAudioImpl _$$DownloadedAudioImplFromJson(
        Map<String, dynamic> json) =>
    _$DownloadedAudioImpl(
      id: json['id'] as String,
      zikrId: json['zikrId'] as String,
      sheikhId: json['sheikhId'] as String,
      localPath: json['localPath'] as String,
      fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
    );

Map<String, dynamic> _$$DownloadedAudioImplToJson(
        _$DownloadedAudioImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'zikrId': instance.zikrId,
      'sheikhId': instance.sheikhId,
      'localPath': instance.localPath,
      'fileSizeBytes': instance.fileSizeBytes,
      'downloadedAt': instance.downloadedAt.toIso8601String(),
    };
