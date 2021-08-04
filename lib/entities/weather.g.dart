// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIUIWeather _$AIUIWeatherFromJson(Map<String, dynamic> json) {
  return AIUIWeather(
    airData: json['airData'] as int?,
    airQuality: json['airQuality'] as String?,
    city: json['city'] as String?,
    date: json['date'] as String?,
    dateLong: json['dateLong'] as int?,
    dateForVoice: json['date_for_voice'] as String?,
    exp: json['exp'] == null
        ? null
        : AIUIWeatherExp.fromJson(json['exp'] as Map<String, dynamic>),
    humidity: json['humidity'] as String?,
    img: json['img'] as String?,
    lastUpdateTime: json['lastUpdateTime'] as String?,
    pm25: json['pm25'] as String?,
    precipitation: json['precipitation'] as String?,
    temp: json['temp'] as int?,
    tempHigh: json['tempHigh'] as String?,
    tempLow: json['tempLow'] as String?,
    tempRange: json['tempRange'] as String?,
    tempReal: json['tempReal'] as String?,
    warning: json['warning'] as String?,
    weather: json['weather'] as String?,
    weatherDescription: json['weatherDescription'] as String?,
    weatherDescription3: json['weatherDescription3'] as String?,
    weatherDescription7: json['weatherDescription7'] as String?,
    weatherType: json['weatherType'] as int?,
    week: json['week'] as String?,
    wind: json['wind'] as String?,
    windLevel: json['windLevel'] as int?,
  );
}

Map<String, dynamic> _$AIUIWeatherToJson(AIUIWeather instance) =>
    <String, dynamic>{
      'airData': instance.airData,
      'airQuality': instance.airQuality,
      'city': instance.city,
      'date': instance.date,
      'dateLong': instance.dateLong,
      'date_for_voice': instance.dateForVoice,
      'exp': instance.exp,
      'humidity': instance.humidity,
      'img': instance.img,
      'lastUpdateTime': instance.lastUpdateTime,
      'pm25': instance.pm25,
      'precipitation': instance.precipitation,
      'temp': instance.temp,
      'tempHigh': instance.tempHigh,
      'tempLow': instance.tempLow,
      'tempRange': instance.tempRange,
      'tempReal': instance.tempReal,
      'warning': instance.warning,
      'weather': instance.weather,
      'weatherDescription': instance.weatherDescription,
      'weatherDescription3': instance.weatherDescription3,
      'weatherDescription7': instance.weatherDescription7,
      'weatherType': instance.weatherType,
      'week': instance.week,
      'wind': instance.wind,
      'windLevel': instance.windLevel,
    };
