// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_exp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIUIWeatherExp _$AIUIWeatherExpFromJson(Map<String, dynamic> json) {
  return AIUIWeatherExp(
    ct: json['ct'] == null
        ? null
        : AIUIWeatherExpCommon.fromJson(json['ct'] as Map<String, dynamic>),
    dy: json['dy'] == null
        ? null
        : AIUIWeatherExpCommon.fromJson(json['dy'] as Map<String, dynamic>),
    gm: json['gm'] == null
        ? null
        : AIUIWeatherExpCommon.fromJson(json['gm'] as Map<String, dynamic>),
    jt: json['jt'] == null
        ? null
        : AIUIWeatherExpCommon.fromJson(json['jt'] as Map<String, dynamic>),
    tr: json['tr'] == null
        ? null
        : AIUIWeatherExpCommon.fromJson(json['tr'] as Map<String, dynamic>),
    uv: json['uv'] == null
        ? null
        : AIUIWeatherExpCommon.fromJson(json['uv'] as Map<String, dynamic>),
    xc: json['xc'] == null
        ? null
        : AIUIWeatherExpCommon.fromJson(json['xc'] as Map<String, dynamic>),
    yd: json['yd'] == null
        ? null
        : AIUIWeatherExpCommon.fromJson(json['yd'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AIUIWeatherExpToJson(AIUIWeatherExp instance) =>
    <String, dynamic>{
      'ct': instance.ct,
      'dy': instance.dy,
      'gm': instance.gm,
      'jt': instance.jt,
      'tr': instance.tr,
      'uv': instance.uv,
      'xc': instance.xc,
      'yd': instance.yd,
    };
