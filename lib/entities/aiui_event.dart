
class AIUIEvent {
  int? arg1;
  int? arg2;
  String? data;
  int? eventType;
  String? info;

  AIUIEvent({this.arg1, this.arg2, this.data, this.eventType, this.info});

  factory AIUIEvent.fromJson(dynamic json) {
    if (json == null) return AIUIEvent();
    Map<String, dynamic> map = Map<String, dynamic>.from(json);
    return AIUIEvent(
        arg1: map['arg1'] as int,
        arg2: map['arg2'] as int,
        data: map['data'] as String,
        eventType: map['eventType'] as int,
        info: map['info'] as String);
  }
}
