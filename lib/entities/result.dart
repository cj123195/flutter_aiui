
import '../aiui.dart';

/// 标识用户请求响应的状态
enum Rc { success, error, system_error, operate_failure, cannot_handle }

class AIUIResult {
  Rc? rc;
  dynamic error;
  String? text;
  String? vendor;
  String? service;
  List<AIUISemanticResult>? semantic;
  dynamic data;
  AIUIAnswerResult? answer;
  String? dialogStat;
  List<AIUIResult>? moreResults;
  bool? shouldEndSession;
  String? uuid;
  String? version;
  dynamic usedState;
  dynamic state;
  String? sid;
  bool? saveHistory;

  AIUIResult(
      {this.rc,
      this.error,
      this.text,
      this.vendor,
      this.service,
      this.semantic,
      this.data,
      this.dialogStat,
      this.usedState,
      this.sid,
      this.uuid,
      this.state,
      this.version,
      this.saveHistory,
      this.answer,
      this.moreResults,
      this.shouldEndSession});

  factory AIUIResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AIUIResult();
    Map<int, Rc> rcMap = {
      0: Rc.success,
      1: Rc.error,
      2: Rc.system_error,
      3: Rc.operate_failure,
      4: Rc.cannot_handle,
    };
    List<AIUIResult>? _moreResults;
    if (json['moreResults'] != null)
      _moreResults = (json['moreResults'] as List)
          .map<AIUIResult>((e) => AIUIResult.fromJson(e))
          .toList();
    List<AIUISemanticResult> _semantic = <AIUISemanticResult>[];
    if (json['semantic'] != null)
      _semantic.addAll((json['semantic'] as List)
          .map<AIUISemanticResult>((e) => AIUISemanticResult.fromJson(e))
          .toList());
    return AIUIResult(
        rc: rcMap[json['rc'] ?? 0],
        error: json['error'],
        text: json['text'],
        vendor: json['vendor'],
        service: json['service'],
        semantic: json['semantic'] == null ? null : _semantic,
        data: dataHandler(json['service'], json['data']),
        answer: AIUIAnswerResult.fromJson(json['answer']),
        dialogStat: json['dialog_stat'],
        moreResults: _moreResults,
        shouldEndSession: json['shouldEndSession'],
        uuid: json['uuid'],
        version: json['version'],
        usedState: json['used_state'],
        state: json['state'],
        sid: json['sid'],
        saveHistory: json['save_history']);
  }

  static dataHandler(String service, dynamic data) {
    dynamic resultData;
    if (data == null || data['result'] == null) return null;
    switch (service) {
      case 'weather':
        if (data['result'] is List)
          resultData = (data['result'] as List)
              .map((e) => AIUIWeather.fromJson(e))
              .toList();
        else
          resultData = data['result'];
        break;
      default:
        resultData = data['result'];
    }
    return resultData;
  }
}

class AIUIAnswerResult {
  String? text;
  String? type;
  String? imgUrl;
  String? imgDesc;
  String? url;
  String? urlDesc;
  String? emotion;

  AIUIAnswerResult(
      {this.text,
      this.type,
      this.imgUrl,
      this.imgDesc,
      this.url,
      this.urlDesc,
      this.emotion});

  factory AIUIAnswerResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AIUIAnswerResult();
    return AIUIAnswerResult(
      text: json['text'],
      type: json['type'],
      imgUrl: json['imgUrl'],
      imgDesc: json['imgDesc'],
      url: json['url'],
      urlDesc: json['urlDesc'],
      emotion: json['emotion'],
    );
  }
}

class AIUISemanticResult {
  String? intent;
  List<AIUISlot>? slots;

  AIUISemanticResult({this.intent, this.slots});

  factory AIUISemanticResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AIUISemanticResult();
    List<AIUISlot> _slots = <AIUISlot>[];
    if (json['slots'] != null)
      _slots.addAll((json['slots'] as List)
          .map<AIUISlot>((e) => AIUISlot.formJson(e))
          .toList());
    return AIUISemanticResult(intent: json['intent'], slots: _slots);
  }
}

class AIUISlot {
  String? name;
  String? value;

  AIUISlot({this.name, this.value});

  factory AIUISlot.formJson(Map<String, dynamic>? json) {
    if (json == null) return AIUISlot();
    return AIUISlot(
        name: json['name'], value: json['value']);
  }
}
