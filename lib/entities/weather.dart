import 'package:json_annotation/json_annotation.dart';

import 'weather_exp.dart';

part 'weather.g.dart';

@JsonSerializable()
class AIUIWeather {
  int? airData;
  String? airQuality;
  String? city;
  String? date;
  int? dateLong;
  @JsonKey(name: "date_for_voice")
  String? dateForVoice;
  AIUIWeatherExp? exp;
  String? humidity;
  String? img;
  String? lastUpdateTime;
  String? pm25;
  String? precipitation;
  int? temp;
  String? tempHigh;
  String? tempLow;
  String? tempRange;
  String? tempReal;
  String? warning;
  String? weather;
  String? weatherDescription;
  String? weatherDescription3;
  String? weatherDescription7;
  int? weatherType;
  String? week;
  String? wind;
  int? windLevel;

  AIUIWeather(
      {this.airData,
      this.airQuality,
      this.city,
      this.date,
      this.dateLong,
      this.dateForVoice,
      this.exp,
      this.humidity,
      this.img,
      this.lastUpdateTime,
      this.pm25,
      this.precipitation,
      this.temp,
      this.tempHigh,
      this.tempLow,
      this.tempRange,
      this.tempReal,
      this.warning,
      this.weather,
      this.weatherDescription,
      this.weatherDescription3,
      this.weatherDescription7,
      this.weatherType,
      this.week,
      this.wind,
      this.windLevel});

  factory AIUIWeather.fromJson(Map<String, dynamic> json) =>
      _$AIUIWeatherFromJson(json);

  Map<String, dynamic> toJson() => _$AIUIWeatherToJson(this);

  // factory AIUIWeather.fromJson(Map<String, dynamic>? json) {
  //   if(json == null)
  //     return AIUIWeather();
  //   return AIUIWeather(
  //     airData: json['airData'],
  //     airQuality: json['airQuality'],
  //     city: json['city'],
  //     date: json['date'],
  //     dateLong: json['dateLong'],
  //     dateForVoice: json['date_for_voice'],
  //     exp: AIUIWeatherExp.fromJson(json['exp']),
  //     humidity: json['humidity'],
  //     img: json['img'],
  //     lastUpdateTime: json['lastUpdateTime'],
  //     pm25: json['pm25'],
  //     precipitation: json['precipitation'],
  //     temp: json['temp'],
  //     tempHigh: json['tempHigh'],
  //     tempLow: json['tempLow'],
  //     tempRange: json['tempRange'],
  //     tempReal: json['tempReal'],
  //     warning: json['warning'],
  //     weather: json['weather'],
  //     weatherDescription: json['weatherDescription'],
  //     weatherDescription3: json['weatherDescription3'],
  //     weatherDescription7: json['weatherDescription7'],
  //     weatherType: json['weatherType'],
  //     week: json['week'],
  //     wind: json['wind'],
  //     windLevel: json['windLevel'],
  //   );
  // }
}


