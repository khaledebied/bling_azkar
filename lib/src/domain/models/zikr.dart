import 'package:freezed_annotation/freezed_annotation.dart';

part 'zikr.freezed.dart';
part 'zikr.g.dart';

@freezed
class Zikr with _$Zikr {
  const factory Zikr({
    required String id,
    required LocalizedText title,
    required String text,
    required LocalizedText translation,
    required String category,
    required int defaultCount,
    required List<AudioInfo> audio,
  }) = _Zikr;

  factory Zikr.fromJson(Map<String, dynamic> json) => _$ZikrFromJson(json);
}

@freezed
class LocalizedText with _$LocalizedText {
  const factory LocalizedText({
    required String en,
    required String ar,
  }) = _LocalizedText;

  factory LocalizedText.fromJson(Map<String, dynamic> json) =>
      _$LocalizedTextFromJson(json);
}

@freezed
class AudioInfo with _$AudioInfo {
  const factory AudioInfo({
    required String sheikhId,
    required String shortFile,
    required String fullFileUrl,
  }) = _AudioInfo;

  factory AudioInfo.fromJson(Map<String, dynamic> json) =>
      _$AudioInfoFromJson(json);
}
