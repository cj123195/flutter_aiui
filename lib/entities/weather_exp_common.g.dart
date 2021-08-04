// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_exp_common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIUIWeatherExpCommon _$AIUIWeatherExpCommonFromJson(Map<String, dynamic> json) {
  return AIUIWeatherExpCommon(
    expName: json['expName'] as String?,
    level: json['level'] as String?,
    prompt: json['prompt'] as String?,
  );
}

Map<String, dynamic> _$AIUIWeatherExpCommonToJson(
        AIUIWeatherExpCommon instance) =>
    <String, dynamic>{
      'expName': instance.expName,
      'level': instance.level,
      'prompt': instance.prompt,
    };
