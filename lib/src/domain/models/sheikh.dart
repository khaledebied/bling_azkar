import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'sheikh.freezed.dart';
part 'sheikh.g.dart';

@freezed
@HiveType(typeId: 2)
class Sheikh with _$Sheikh {
  const factory Sheikh({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String nameAr,
    @HiveField(3) required String bio,
    @HiveField(4) required String imageUrl,
    @HiveField(5) @Default(false) bool isDownloaded,
    @HiveField(6) @Default([]) List<String> downloadedAudioIds,
  }) = _Sheikh;

  factory Sheikh.fromJson(Map<String, dynamic> json) => _$SheikhFromJson(json);
}

@freezed
@HiveType(typeId: 3)
class DownloadedAudio with _$DownloadedAudio {
  const factory DownloadedAudio({
    @HiveField(0) required String id,
    @HiveField(1) required String zikrId,
    @HiveField(2) required String sheikhId,
    @HiveField(3) required String localPath,
    @HiveField(4) required int fileSizeBytes,
    @HiveField(5) required DateTime downloadedAt,
  }) = _DownloadedAudio;

  factory DownloadedAudio.fromJson(Map<String, dynamic> json) =>
      _$DownloadedAudioFromJson(json);
}
