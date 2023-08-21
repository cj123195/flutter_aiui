/// 事件类型
enum EventType {
  result(1),
  error(2),
  state(3),
  wakeup(4),
  sleep(5),
  vad(6),
  cmdReturn(8),
  preSleep(10),
  startRecord(11),
  stopRecord(12),
  connectedToServer(13),
  serverDisconnected(14),
  tts(15);

  const EventType(this.value);

  final int value;

  static EventType? tryParse(int value) {
    for (EventType event in EventType.values) {
      if (event.value == value) {
        return event;
      }
    }
    return null;
  }
}

/// 事件
class AiuiEvent {
  AiuiEvent({
    required this.arg1,
    required this.arg2,
    required this.data,
    required this.info,
    this.eventType,
  });

  factory AiuiEvent.fromJson(Map json) {
    return AiuiEvent(
      arg1: json['arg1'] as int,
      arg2: json['arg2'] as int,
      data: json['data'] as Map,
      eventType: EventType.tryParse(json['eventType']),
      info: json['info'] as String,
    );
  }

  int arg1;
  int arg2;
  Map data;

  /// {
  ///     "data": [{
  ///         "params": {
  ///             "sub": "iat",
  ///         },
  ///         "content": [{
  ///             "dte": "utf8",
  ///             "dtf": "json",
  ///             "cnt_id": "0"
  ///         }]
  ///     }]
  // }
  String info;
  EventType? eventType;
}
