import 'package:flutter_aiui/listener.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_aiui_method_channel.dart';
import 'models/parameter.dart';

abstract class FlutterAiuiPlatform extends PlatformInterface {
  /// Constructs a FlutterAiuiPlatform.
  FlutterAiuiPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterAiuiPlatform _instance = MethodChannelFlutterAiui();

  /// The default instance of [FlutterAiuiPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterAiui].
  static FlutterAiuiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterAiuiPlatform] when
  /// they register themselves.
  static set instance(FlutterAiuiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 创建AIUI代理
  ///
  /// [params] AIUI配置
  /// [listener] 监听器
  Future<void> initAgent(
    AiuiParams params, {
    AiuiEventListener? listener,
  }) {
    throw UnimplementedError('createAgent() has not been implemented.');
  }

  /// 销毁AIUI代理
  Future<void> destroyAgent() {
    throw UnimplementedError('destroyAgent() has not been implemented.');
  }

  /// 添加监听器
  void addListener(AiuiEventListener listener) {
    throw UnimplementedError('addListener() has not been implemented.');
  }

  /// 删除监听器
  void removeListener() {
    throw UnimplementedError('removeListener() has not been implemented.');
  }

  /// 设置参数
  Future<void> setParams(AiuiParams params) {
    throw UnimplementedError('setParams() has not been implemented.');
  }

  /// 开始录音
  Future<void> startRecordAudio([IatAudioParams? params]) {
    throw UnimplementedError('startRecordAudio() has not been implemented.');
  }

  /// 暂停录音
  Future<void> pauseRecordAudio([IatAudioParams? params]) {
    throw UnimplementedError('pauseRecordAudio() has not been implemented.');
  }

  /// 继续录音
  Future<void> resumeRecordAudio([IatAudioParams? params]) {
    throw UnimplementedError('resumeRecordAudio() has not been implemented.');
  }

  /// 结束录音
  Future<void> stopRecordAudio([IatAudioParams? params]) {
    throw UnimplementedError('stopRecordAudio() has not been implemented.');
  }

  /// 文本语义
  Future<void> writeText(String text, [IatTextParams? params]) {
    throw UnimplementedError('writeText() has not been implemented.');
  }

  /// 语音合成
  Future<void> startTTS(String text, [TtsParams? params]) {
    throw UnimplementedError('startTTS() has not been implemented.');
  }

  /// 暂停语音合成
  Future<void> pauseTTS() {
    throw UnimplementedError('pauseTTS() has not been implemented.');
  }

  /// 继续语音合成
  Future<void> resumeTTS([TtsParams? params]) {
    throw UnimplementedError('resumeTTS() has not been implemented.');
  }

  /// 停止语音合成
  Future<void> stopTTS() {
    throw UnimplementedError('stopTTS() has not been implemented.');
  }
}
