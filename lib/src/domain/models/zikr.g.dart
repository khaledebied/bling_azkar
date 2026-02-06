// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zikr.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ZikrImpl _$$ZikrImplFromJson(Map<String, dynamic> json) => _$ZikrImpl(
      id: json['id'] as String,
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
      text: json['text'] as String,
      translation: json['translation'] == null
          ? null
          : LocalizedText.fromJson(json['translation'] as Map<String, dynamic>),
      category: json['category'] as String,
      defaultCount: (json['defaultCount'] as num).toInt(),
      reference: json['reference'] as String?,
    );

Map<String, dynamic> _$$ZikrImplToJson(_$ZikrImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'text': instance.text,
      'translation': instance.translation,
      'category': instance.category,
      'defaultCount': instance.defaultCount,
      'reference': instance.reference,
    };

_$LocalizedTextImpl _$$LocalizedTextImplFromJson(Map<String, dynamic> json) =>
    _$LocalizedTextImpl(
      en: json['en'] as String,
      ar: json['ar'] as String,
    );

Map<String, dynamic> _$$LocalizedTextImplToJson(_$LocalizedTextImpl instance) =>
    <String, dynamic>{
      'en': instance.en,
      'ar': instance.ar,
    };
