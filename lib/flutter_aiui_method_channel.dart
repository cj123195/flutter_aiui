import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aiui/constant.dart';
import 'package:flutter_aiui/listener.dart';
import 'package:flutter_aiui/models/event.dart';
import 'package:flutter_aiui/models/i_trans_result.dart';
import 'package:flutter_aiui/models/tts_result.dart';

import 'flutter_aiui_platform_interface.dart';
import 'models/iat_result.dart';
import 'models/nlp_result.dart';
import 'models/parameter.dart';

/// 结果类型
enum _ResultType {
  /// 听写结果
  iat,

  /// 语义结果
  nlp,

  /// 后处理服务结果
  tpp,

  /// 云端tts结果
  tts,

  /// 翻译结果
  itrans;

  static _ResultType? tryParse(String? sub) {
    for (_ResultType type in _ResultType.values) {
      if (type.name == sub) {
        return type;
      }
    }
    return null;
  }
}

/// An implementation of [FlutterAiuiPlatform] that uses method channels.
class MethodChannelFlutterAiui extends FlutterAiuiPlatform {
  AiuiEventListener? _listener;

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_aiui');

  /// 创建AIUI代理
  ///
  /// [params] AIUI配置
  /// [listener] 监听器
  @override
  Future<void> initAgent(
    AiuiParams params, {
    AiuiEventListener? listener,
  }) {
    if (listener != null) {
      addListener(listener);
    }
    return methodChannel.invokeMethod(
      AiuiConstant.initAgent,
      jsonEncode(params.toMap()),
    );
  }

  /// 销毁AIUI代理
  @override
  Future<void> destroyAgent() async {
    if (_listener != null) {
      _listener = null;
    }
    await methodChannel.invokeMethod(AiuiConstant.destroyAgent);
  }

  @override
  void addListener(AiuiEventListener listener) {
    _listener = listener;
    methodChannel.setMethodCallHandler((call) async {
      if (_listener == null) {
        return;
      }
      if (call.method == AiuiConstant.onEvent) {
        final AiuiEvent event = AiuiEvent.fromJson(call.arguments as Map);
        switch (event.eventType) {
          case EventType.result:
            _listener?.onResult?.call(event);
            _processResult(event);
            break;
          case EventType.error:
            _listener!.onError?.call(event.arg1, event.info);
            break;
          case EventType.state:
            _listener!.onStateChange?.call(event.arg1);
            break;
          case EventType.wakeup:
            _listener!.onWakeup?.call(WakeupType.parse(event.arg1), event.info);
            break;
          case EventType.sleep:
            _listener!.onSleep?.call(SleepType.parse(event.arg1));
            break;
          case EventType.vad:
            final VadEventType eventType = VadEventType.parse(event.arg1);
            _listener!.onVad?.call(
              eventType,
              eventType == VadEventType.volume ? event.arg2 : null,
            );
            break;
          case EventType.cmdReturn:
            _listener!.onCmdReturn?.call(event.arg1, event.arg2, event.info);
            break;
          case EventType.preSleep:
            _listener!.onPreSleep?.call();
            break;
          case EventType.startRecord:
            _listener!.onRecordStart?.call();
            break;
          case EventType.stopRecord:
            _listener!.onRecordStop?.call();
            break;
          case EventType.connectedToServer:
            _listener!.onConnectedToServer?.call();
            break;
          case EventType.serverDisconnected:
            _listener!.onServerDisconnected?.call();
            break;
          case EventType.tts:
            _listener!.onTts?.call();
            break;
          default:
            break;
        }
      }
    });
  }

  /// 处理AIUI结果
  /// [event] AIUI结果事件
  void _processResult(AiuiEvent event) {
    // 解析结果
    final Map<String, dynamic> bizParam = jsonDecode(event.info);
    // 事件数据
    final Map<String, dynamic> eventData = event.data.cast<String, dynamic>();
    // 由于结果返回的数据可能是多条，这里我们默认取第一条数据
    final Map<String, dynamic> bizData = bizParam['data']?.first;

    ///结果内容参数，根据参数来判断是何种类型数据并调用响应监听器返回结果
    final Map<String, dynamic> params = bizData['params'];

    if ((bizData['content'] as List?)?.isNotEmpty != true) {
      return;
    }
    // 由于结果返回的内容可能是多条，这里我们默认取第一条内容
    final Map<String, dynamic> content = bizData['content'].first;

    /// 解析结果类型，如果是未知类型不执行任何操作
    final _ResultType? resultType = _ResultType.tryParse(params['sub']);
    if (resultType == null) {
      return;
    }

    // 内容对应事件数据id
    final String? cntId = content['cnt_id'];
    if (cntId == null) {
      return;
    }

    final int rspTime = eventData['eos_rslt'] ?? -1; //响应时间

    final Uint8List bytes = Uint8List.fromList(eventData[cntId]?.cast<int>());

    switch (resultType) {
      case _ResultType.iat:
        final Map<String, dynamic> cntParam = jsonDecode(utf8.decode(bytes));
        if (cntParam['text'] != null) {
          _listener?.onIatResult?.call(
            IatResult.fromJson(cntParam['text']),
            rspTime,
          );
        }
        break;
      case _ResultType.nlp:
        final Map<String, dynamic> cntParam = jsonDecode(utf8.decode(bytes));
        if (cntParam['intent'] != null) {
          _listener?.onNlpResult?.call(
            NlpResult.fromJson(cntParam['intent']),
            rspTime,
          );
        }
        break;
      case _ResultType.tpp:
        _listener?.onTppResult?.call(event);
        break;
      case _ResultType.tts:
        final int dts = content['dts'];
        final int frameId = content['frame_id'];
        final int percent = eventData['percent'];
        final bool isCancel = content['cancel'] == 1;
        _listener?.onTtsResult?.call(
          TtsResult(
            dts: TtsDts.parse(dts),
            frameId: frameId,
            isCancel: isCancel,
            audioData: bytes,
            percent: percent,
          ),
        );
        break;
      case _ResultType.itrans:
        final Map<String, dynamic> cntParam = jsonDecode(utf8.decode(bytes));
        final Map json = cntParam['trans_result'];
        json['sid'] = eventData['sid'] ?? '';
        _listener?.onITransResult?.call(ITransResult.fromJson(json));
        break;
      default:
        break;
    }
  }

  @override
  void removeListener() {
    _listener = null;
  }

  /// 设置参数
  @override
  Future<void> setParams(AiuiParams params) {
    return methodChannel.invokeMethod(
      AiuiConstant.setParams,
      jsonEncode(params.toMap()),
    );
  }

  /// 开始录音
  @override
  Future<void> startRecordAudio([IatAudioParams? params]) {
    return methodChannel.invokeMethod(
      AiuiConstant.startRecordAudio,
      params == null ? null : jsonEncode(params.toMap()),
    );
  }

  /// 暂停录音
  @override
  Future<void> pauseRecordAudio([IatAudioParams? params]) {
    return methodChannel.invokeMethod(
      AiuiConstant.pauseRecordAudio,
      params == null ? null : jsonEncode(params.toMap()),
    );
  }

  /// 继续录音
  @override
  Future<void> resumeRecordAudio([IatAudioParams? params]) {
    return methodChannel.invokeMethod(
      AiuiConstant.resumeRecordAudio,
      params == null ? null : jsonEncode(params.toMap()),
    );
  }

  /// 结束录音
  @override
  Future<void> stopRecordAudio([IatAudioParams? params]) {
    return methodChannel.invokeMethod(
      AiuiConstant.stopRecordAudio,
      params == null ? null : jsonEncode(params.toMap()),
    );
  }

  /// 文本语义
  @override
  Future<void> writeText(String text, [IatTextParams? params]) {
    return methodChannel.invokeMethod(
      AiuiConstant.writeText,
      {
        'text': text,
        'config': params == null ? null : jsonEncode(params.toMap()),
      },
    );
  }

  /// 语音合成
  @override
  Future<void> startTTS(String text, [TtsParams? params]) {
    return methodChannel.invokeMethod(AiuiConstant.startTTS, {
      'text': text,
      if (params != null) 'config': jsonEncode(params.toMap()),
    });
  }

  /// 暂停语音合成
  @override
  Future<void> pauseTTS() {
    return methodChannel.invokeMethod(AiuiConstant.pauseTTS);
  }

  /// 继续语音合成
  @override
  Future<void> resumeTTS([TtsParams? params]) {
    return methodChannel.invokeMethod(
      AiuiConstant.resumeTTS,
      params == null ? null : jsonEncode(params.toMap()),
    );
  }

  /// 停止语音合成
  @override
  Future<void> stopTTS() {
    return methodChannel.invokeMethod(AiuiConstant.stopTTS);
  }
}
