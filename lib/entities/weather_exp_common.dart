import 'package:json_annotation/json_annotation.dart';

part 'weather_exp_common.g.dart';

@JsonSerializable()
class AIUIWeatherExpCommon {
  String? expName;
  String? level;
  String? prompt;

  AIUIWeatherExpCommon({this.expName, this.level, this.prompt});

  factory AIUIWeatherExpCommon.fromJson(Map<String, dynamic> json) =>
      _$AIUIWeatherExpCommonFromJson(json);

  Map<String, dynamic> toJson() => _$AIUIWeatherExpCommonToJson(this);

// factory AIUIWeatherExpCommon.fromJson(Map<String, dynamic>? json) {
//   if (json == null) return AIUIWeatherExpCommon();
//   return AIUIWeatherExpCommon(
//     expName: json['expName'],
//     level: json['level'],
//     prompt: json['prompt'],
//   );
// }
}