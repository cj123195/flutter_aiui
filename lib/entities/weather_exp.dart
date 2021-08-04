import 'package:json_annotation/json_annotation.dart';

import 'weather_exp_common.dart';

part 'weather_exp.g.dart';

@JsonSerializable()
class AIUIWeatherExp {
  AIUIWeatherExpCommon? ct;
  AIUIWeatherExpCommon? dy;
  AIUIWeatherExpCommon? gm;
  AIUIWeatherExpCommon? jt;
  AIUIWeatherExpCommon? tr;
  AIUIWeatherExpCommon? uv;
  AIUIWeatherExpCommon? xc;
  AIUIWeatherExpCommon? yd;

  AIUIWeatherExp(
      {this.ct, this.dy, this.gm, this.jt, this.tr, this.uv, this.xc, this.yd});

  factory AIUIWeatherExp.fromJson(Map<String, dynamic> json) =>
      _$AIUIWeatherExpFromJson(json);

  Map<String, dynamic> toJson() => _$AIUIWeatherExpToJson(this);
//
// factory AIUIWeatherExp.fromJson(Map<String, dynamic>? json) {
//   if (json == null) return AIUIWeatherExp();
//   return AIUIWeatherExp(
//     ct: AIUIWeatherExpCommon.fromJson(json['ct']),
//     dy: AIUIWeatherExpCommon.fromJson(json['dy']),
//     gm: AIUIWeatherExpCommon.fromJson(json['gm']),
//     jt: AIUIWeatherExpCommon.fromJson(json['jt']),
//     tr: AIUIWeatherExpCommon.fromJson(json['tr']),
//     uv: AIUIWeatherExpCommon.fromJson(json['uv']),
//     xc: AIUIWeatherExpCommon.fromJson(json['xc']),
//     yd: AIUIWeatherExpCommon.fromJson(json['yd']),
//   );
// }
}