import 'package:flutter_aiui/models/parameter.dart';

import 'flutter_aiui_platform_interface.dart';
import 'listener.dart';

export 'constant.dart';
export 'listener.dart';
export 'models/iat_result.dart';
export 'models/nlp_result.dart';
export 'models/parameter.dart';

class FlutterAiui {
  factory FlutterAiui() => FlutterAiui.instance;

  FlutterAiui._();

  static FlutterAiui get instance => FlutterAiui._();

  /// 创建AIUI代理
  ///
  /// [params] AIUI配置
  /// [listener] 监听器
  Future<void> initAgent(
    AiuiParams params, {
    AiuiEventListener? listener,
  }) {
    return FlutterAiuiPlatform.instance.initAgent(
      params,
      listener: listener,
    );
  }

  /// 销毁AIUI代理
  Future<void> destroyAgent() {
    return FlutterAiuiPlatform.instance.destroyAgent();
  }

  /// 添加监听器
  void addListener(AiuiEventListener listener) {
    return FlutterAiuiPlatform.instance.addListener(listener);
  }

  /// 删除监听器
  void removeListener() {
    return FlutterAiuiPlatform.instance.removeListener();
  }

  /// 设置参数
  Future<void> setParams(AiuiParams params) {
    return FlutterAiuiPlatform.instance.setParams(params);
  }

  /// 开始录音
  Future<void> startRecordAudio([IatAudioParams? params]) {
    return FlutterAiuiPlatform.instance.startRecordAudio(params);
  }

  /// 暂停录音
  Future<void> pauseRecordAudio([IatAudioParams? params]) {
    return FlutterAiuiPlatform.instance.pauseRecordAudio(params);
  }

  /// 继续录音
  Future<void> resumeRecordAudio([IatAudioParams? params]) {
    return FlutterAiuiPlatform.instance.resumeRecordAudio(params);
  }

  /// 结束录音
  Future<void> stopRecordAudio([IatAudioParams? params]) {
    return FlutterAiuiPlatform.instance.stopRecordAudio(params);
  }

  /// 文本语义
  Future<void> writeText(String text, [IatTextParams? params]) {
    return FlutterAiuiPlatform.instance.writeText(text, params);
  }

  /// 语音合成
  Future<void> startTTS(String text, [TtsParams? params]) {
    return FlutterAiuiPlatform.instance.startTTS(text, params);
  }

  /// 暂停语音合成
  Future<void> pauseTTS() {
    return FlutterAiuiPlatform.instance.pauseTTS();
  }

  /// 继续语音合成
  Future<void> resumeTTS([TtsParams? params]) {
    return FlutterAiuiPlatform.instance.resumeTTS(params);
  }

  /// 停止语音合成
  Future<void> stopTTS() {
    return FlutterAiuiPlatform.instance.stopTTS();
  }
}
