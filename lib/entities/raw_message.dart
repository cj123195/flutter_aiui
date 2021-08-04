
enum MsgType { TEXT, Voice }

enum FromType { USER, AIUI }

/// 交互消息原始数据
class RawMessage {
  static int sMsgIDStore = 0;

  int? msgID;
  late int msgVersion;
  int? responseTime;
  FromType? fromType;
  MsgType? msgType;
  String? cacheContent;
  dynamic msgData;

  RawMessage(
      {FromType? fromType,
      MsgType? msgType,
      dynamic msgData,
      String? cacheContent,
      int? responseTime}) {
    this.msgID = sMsgIDStore++;
    this.fromType = fromType;
    this.msgType = msgType;
    this.msgData = msgData;
    this.responseTime = responseTime;
    this.msgVersion = 0;
    this.cacheContent = cacheContent;
  }

  bool isText() {
    return msgType == MsgType.TEXT;
  }

  bool get isEmptyContent {
    return cacheContent?.isEmpty ?? true;
  }

  bool get isFromUser {
    return fromType == FromType.USER;
  }

  int? get version {
    return msgVersion;
  }

  void versionUpdate() {
    msgVersion++;
  }

  int getAudioLen() {
    if (msgType == MsgType.Voice) {
      return msgData;
    } else {
      return 0;
    }
  }
}
