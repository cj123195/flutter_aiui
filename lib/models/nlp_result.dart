/// 用于标识用户请求响应的状态，它包含用户操作成功或异常等几个方面的状态编号。当存在多个候选的
/// 响应结果时，每个响应结果内都必须包含相应的rc码，便于客户端对每个响应包进行识别和操作
enum Rc {
  /// 操作成功
  success,

  /// 输入异常
  error,

  /// 系统内部异常
  systemError,

  /// 业务操作失败，没搜索到结果或信源异常
  operateFailure,

  /// 文本没有匹配的技能场景，技能不理解或不能处理该文本
  cannotHandle;

  static Rc parse(int? value) {
    for (Rc rc in Rc.values) {
      if (rc.index == value) {
        return rc;
      }
    }
    return Rc.success;
  }
}

/// 语义结果实体
class NlpResult {
  NlpResult({
    required this.rc,
    required this.text,
    required this.uuid,
    required this.sid,
    this.service,
    this.category,
    this.error,
    this.vendor,
    this.semantic,
    this.data,
    this.dialogStat,
    this.usedState,
    this.state,
    this.version,
    this.saveHistory,
    this.answer,
    this.moreResults,
    this.shouldEndSession,
  });

  factory NlpResult.fromJson(Map json) {
    final List<Map>? moreResultsJson = json['moreResults']?.cast<Map>();
    final List<NlpResult>? moreResults =
        moreResultsJson?.map<NlpResult>(NlpResult.fromJson).toList();

    final AiuiData? data =
        json['data'] == null ? null : AiuiData.fromJson(json['data']);
    final Answer? answer =
        json['answer'] == null ? null : Answer.fromJson(json['answer']);

    final List<Map>? semanticJson = json['semantic']?.cast<Map>();
    final List<Semantic>? semantic =
        semanticJson?.map<Semantic>(Semantic.fromJson).toList();
    return NlpResult(
      rc: Rc.parse(json['rc']),
      error: json['error'],
      text: json['text'],
      vendor: json['vendor'],
      service: json['service'],
      semantic: json['semantic'] == null ? null : semantic,
      data: data,
      answer: answer,
      category: json['category'],
      dialogStat: json['dialog_stat'],
      moreResults: moreResults,
      shouldEndSession: json['shouldEndSession'] == 'true',
      uuid: json['uuid'],
      version: json['version'],
      usedState: json['used_state'],
      state: json['state'],
      sid: json['sid'],
      saveHistory: json['save_history'],
    );
  }

  /// 应答码(response code)
  final Rc rc;

  /// 错误信息
  final dynamic error;

  /// 用户的输入
  ///
  /// 可能和请求中的原始text不完全一致，因服务器可能会对text进行语言纠错
  final String text;

  /// 技能提供者
  ///
  /// 不存在时默认表示为IFLYTEK提供的开放技能
  final String? vendor;

  /// 技能的全局唯一名称，一般为vendor.name
  ///
  /// [vendor]不存在时默认为IFLYTEK提供的开放技能。
  final String? service;

  /// 本次语义（包括历史继承过来的语义）结构化表示，各技能自定义
  final List<Semantic>? semantic;

  /// 数据结构化表示，各技能自定义
  final AiuiData? data;

  /// 对结果内容的最简化文本/图片描述，各技能自定义
  Answer? answer;

  /// 用于客户端判断是否使用信源返回数据
  final String? dialogStat;

  /// 在存在多个候选结果时，用于提供更多的结果描述
  final List<NlpResult>? moreResults;

  /// 当该字段为空或为 true 时表示技能已完成一次对话；
  /// 如果为 false 时，表示技能期待用户输入，远场交互设备此时应该主动打开麦克风拾音
  final bool? shouldEndSession;

  /// 技能类别
  final String? category;

  /// 版本
  final String? version;

  /// 同sid（历史字段，请忽略）
  final String uuid;

  /// 交互使用状态（历史字段，请忽略）
  final dynamic usedState;

  /// 交互状态（历史字段，请忽略）
  final dynamic state;

  /// 会话id，用于标识会话，调试时提供给讯飞帮助定位问题
  final String sid;

  /// 是否有会话历史
  final bool? saveHistory;
}

/// 简化图文结果类型
enum AnswerType {
  ///text数据
  text('T'),

  /// url数据
  url('U'),

  /// text+url数据
  textUrl('TU'),

  /// image+text数据
  imageText('IT'),

  /// image+text+url数据
  imageTextUrl('ITU');

  const AnswerType(this.value);

  final String value;

  static AnswerType? tryParse(String? type) {
    for (AnswerType answerType in AnswerType.values) {
      if (type == answerType.value) {
        return answerType;
      }
    }
    return null;
  }
}

/// 简化图文结果表示
///
/// 对于一些技能，支持直接返回一段文本应答结果，同时辅助一张图片和相关链接。应用可以无需解析和
/// 提取语义/结果的结构化数据信息，直接显示该字段的图文信息。同时用户可以选择通过开放平台编辑和
/// 上传/导入图文应答信息，快速自定义扩展应用交互。
class Answer {
  const Answer({
    required this.text,
    this.type,
    this.imgUrl,
    this.imgDesc,
    this.url,
    this.urlDesc,
    this.emotion,
  });

  factory Answer.fromJson(Map json) {
    return Answer(
      text: json['text'],
      type: AnswerType.tryParse(json['type']),
      imgUrl: json['imgUrl'],
      imgDesc: json['imgDesc'],
      url: json['url'],
      urlDesc: json['urlDesc'],
      emotion: json['emotion'],
    );
  }

  /// 通用的文字显示，属于text数据
  final String text;

  /// 显示的类型，通过这个类型，可以确定数据的返回内容和客户端的显示内容，默认值为 T 。
  final AnswerType? type;

  /// 图片的链接地址，属于image数据
  final String? imgUrl;

  /// 图片的描述文字
  final String? imgDesc;

  /// url链接
  final String? url;

  /// url链接的描述文字
  final String? urlDesc;

  /// 回答的情绪，取值参见附录的情感标签对照表
  final String? emotion;
}

/// 语义结构化表示
class Semantic {
  const Semantic({this.intent, this.slots});

  factory Semantic.fromJson(Map json) {
    final List<Slot> slots = <Slot>[];
    if (json['slots'] != null) {
      slots.addAll(
        (json['slots'] as List).cast<Map>().map<Slot>(Slot.formJson).toList(),
      );
    }
    return Semantic(intent: json['intent'], slots: slots);
  }

  /// 技能中的意图
  final String? intent;

  /// 参照后续不同技能的定义
  final List<Slot>? slots;
}

/// 每个对象表示一个语义槽位信息
class Slot {
  const Slot({this.name, this.value});

  factory Slot.formJson(Map json) {
    return Slot(name: json['name'], value: json['value']);
  }

  /// 槽位名
  final String? name;

  /// 槽位值
  final String? value;
}

///  结构化数据表示
class AiuiData {
  const AiuiData({this.header, this.result});

  factory AiuiData.fromJson(Map json) {
    return AiuiData(header: json['header'], result: json['result']);
  }

  /// 导语部分
  final String? header;

  /// 结构化数据；如果没有查到数据，此字段不返回。参照后续不同技能的定义
  final dynamic result;
}

/// Aiui 天气信息实体
class Weather {
  Weather({
    this.airData,
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
    this.windLevel,
  });

  factory Weather.fromJson(Map json) => Weather(
        airData: json['airData'] as int?,
        airQuality: json['airQuality'] as String?,
        city: json['city'] as String?,
        date: json['date'] as String?,
        dateLong: json['dateLong'] as int?,
        dateForVoice: json['date_for_voice'] as String?,
        exp: json['exp'] == null
            ? null
            : WeatherExp.fromJson(json['exp'] as Map<String, dynamic>),
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
  int? airData;
  String? airQuality;
  String? city;
  String? date;
  int? dateLong;
  String? dateForVoice;
  WeatherExp? exp;
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'airData': airData,
        'airQuality': airQuality,
        'city': city,
        'date': date,
        'dateLong': dateLong,
        'date_for_voice': dateForVoice,
        'exp': exp,
        'humidity': humidity,
        'img': img,
        'lastUpdateTime': lastUpdateTime,
        'pm25': pm25,
        'precipitation': precipitation,
        'temp': temp,
        'tempHigh': tempHigh,
        'tempLow': tempLow,
        'tempRange': tempRange,
        'tempReal': tempReal,
        'warning': warning,
        'weather': weather,
        'weatherDescription': weatherDescription,
        'weatherDescription3': weatherDescription3,
        'weatherDescription7': weatherDescription7,
        'weatherType': weatherType,
        'week': week,
        'wind': wind,
        'windLevel': windLevel,
      };
}

class WeatherExp {
  WeatherExp({
    this.ct,
    this.dy,
    this.gm,
    this.jt,
    this.tr,
    this.uv,
    this.xc,
    this.yd,
  });

  factory WeatherExp.fromJson(Map<String, dynamic> json) => WeatherExp(
        ct: json['ct'] == null
            ? null
            : WeatherExpCommon.fromJson(json['ct'] as Map<String, dynamic>),
        dy: json['dy'] == null
            ? null
            : WeatherExpCommon.fromJson(json['dy'] as Map<String, dynamic>),
        gm: json['gm'] == null
            ? null
            : WeatherExpCommon.fromJson(json['gm'] as Map<String, dynamic>),
        jt: json['jt'] == null
            ? null
            : WeatherExpCommon.fromJson(json['jt'] as Map<String, dynamic>),
        tr: json['tr'] == null
            ? null
            : WeatherExpCommon.fromJson(json['tr'] as Map<String, dynamic>),
        uv: json['uv'] == null
            ? null
            : WeatherExpCommon.fromJson(json['uv'] as Map<String, dynamic>),
        xc: json['xc'] == null
            ? null
            : WeatherExpCommon.fromJson(json['xc'] as Map<String, dynamic>),
        yd: json['yd'] == null
            ? null
            : WeatherExpCommon.fromJson(json['yd'] as Map<String, dynamic>),
      );
  WeatherExpCommon? ct;
  WeatherExpCommon? dy;
  WeatherExpCommon? gm;
  WeatherExpCommon? jt;
  WeatherExpCommon? tr;
  WeatherExpCommon? uv;
  WeatherExpCommon? xc;
  WeatherExpCommon? yd;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'ct': ct,
        'dy': dy,
        'gm': gm,
        'jt': jt,
        'tr': tr,
        'uv': uv,
        'xc': xc,
        'yd': yd,
      };
}

class WeatherExpCommon {
  WeatherExpCommon({this.expName, this.level, this.prompt});

  factory WeatherExpCommon.fromJson(Map<String, dynamic> json) =>
      WeatherExpCommon(
        expName: json['expName'] as String?,
        level: json['level'] as String?,
        prompt: json['prompt'] as String?,
      );
  String? expName;
  String? level;
  String? prompt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'expName': expName,
        'level': level,
        'prompt': prompt,
      };
}

/// 地点类型
enum LocationType {
  /// 基础地点（表示行政区划）的location
  basic('LOC_BASIC'),

  /// 表示道路的location
  street('LOC_STREET'),

  /// 表示交叉路口的location
  cross('LOC_CROSS'),

  /// 表示区域的location
  region('LOC_REGION'),

  /// 表示位置点的location
  poi('LOC_POI');

  const LocationType(this.value);

  final String value;

  static LocationType tryParse(String type) {
    for (LocationType locationType in LocationType.values) {
      if (locationType.value == type) {
        return locationType;
      }
    }
    return LocationType.basic;
  }
}

/// 地点描述相关协议
class Location {
  const Location({
    required this.type,
    this.country,
    this.province,
    this.provinceAddr,
    this.city,
    this.cityAddr,
    this.area,
    this.areaAddr,
    this.street,
    this.streets,
    this.region,
    this.poi,
  });

  factory Location.fromJson(Map json) {
    return Location(
      type: json['location.type'],
      country: json['location.country'],
      province: json['location.province'],
      provinceAddr: json['location.provinceAddr'],
      city: json['location.city'],
      cityAddr: json['location.cityAddr'],
      area: json['location.area'],
      areaAddr: json['location.areaAddr'],
      street: json['location.street'],
      streets: json['location.streets'],
      region: json['location.region'],
      poi: json['location.poi'],
    );
  }

  /// 地点类型
  ///
  /// [LocationType.basic]： [country]、[province]、[city]、[area]这4个至少有一个不为空；
  /// [LocationType.street]： [city]、[street]必选，其他元素可选，当用户没有输入城市，
  /// city为”CURRENT_CITY”；
  /// [LocationType.cross]： [city]、[street]、[streets]必选，其他元素可选，当用户没有
  /// 输入城市而又没有上传所在城市信息，city为”CURRENT_CITY”
  /// [LocationType.region]： [city]、[region]必选，其他元素可选，当用户没有输入城市而又没有
  /// 上传所在城市信息，比如“西直门”，city为“CURRENT_CITY”
  /// [LocationType.poi]： [city]、[poi]必选，其他元素可选，当用户没有输入城市而又没有上传
  /// 所在城市信息， city为“CURRENT_CITY”
  final String type;

  /// 国别简称(参见附录的对照表)
  final String? country;

  /// 省全称（包括直辖市、台）
  final String? province;

  /// 省简称
  final String? provinceAddr;

  /// 市全称（包括港澳）
  final String? city;

  /// 市简称
  final String? cityAddr;

  /// 县区
  final String? area;

  /// 县区简称
  final String? areaAddr;

  /// 道路名称
  final String? street;

  /// 交叉路口的另一道路名称
  final String? streets;

  /// 区域名称
  final String? region;

  /// 机构等名称,CURRENT_POI表示当前地点
  ///
  /// city、poi必选，其他元素可选，当用户没有输入城市而又没有上传所在城市信息， city为“CURRENT_CITY”
  final String? poi;
}
