import 'dart:convert';

import 'package:flutter/services.dart';

import '../aiui.dart';

class AIUIConfigHandler {
  String defaultAssetsPath = "assets/cfg/aiui_phone.cfg";

  late Map<String, dynamic>? _config;

  Map<String, dynamic>? get config => _config;

  AIUIConfigHandler.fromAssets(String path) {
    _config = readConfigFromAssets(path) as Map<String, dynamic>?;
  }

  AIUIConfigHandler(AIUIConfig aiuiConfig)
      : _config = aiuiConfig.toMap();

  void changePlayMode(PlayMode playMode) {
    _config!['tts']['play_mode'] = playMode == PlayMode.user ? 'user' : 'sdk';
  }

  /// 从配置文件读取配置信息
  /// [path] 文件路径
  Future<Map<String, dynamic>>? readConfigFromAssets(String path) async {
    try {
      ByteData data = await rootBundle.load(path);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      String mAIUIConfig = String.fromCharCodes(bytes);
      return jsonDecode(mAIUIConfig);
    } catch (e) {
      throw Null;
    }
  }
}
