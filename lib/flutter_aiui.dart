import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'aiui.dart';
import 'constants/aiui_channel.dart';

class FlutterAIUI {
  static const MethodChannel _channel = const MethodChannel('flutter_aiui');

  static final FlutterAIUI shared = FlutterAIUI._();

  FlutterAIUI._();

  late AIUIConfigHandler _configHandler;
  late AIUIEventListener? _listener;

  RawMessage? _mAppendVoiceMsg;

  String _wakeUpText = '';

  //记录自开始录音是否有vad前端点事件抛出
  bool _mAudioRecording = false;

  //语音消息开始时间，用于计算语音消息持续长度
  int _mAudioStart = DateTime.now().millisecond;
  bool _isWakeupEnable = false;

  //处理PGS听写(流式听写）的数组
  List<String?> _mIATPGSStack = <String?>[]..length = 256;
  List<String> _mInterResultStack = <String>[];

  Map<String, dynamic>? get config => _configHandler.config;

  /// 初始化
  Future<void> init(
      {AIUIConfig? config,
      String? path,
      required String wakeUpText,
      AIUIEventListener? listener}) async {
    assert(config != null || path != null);

    _listener = listener;
    _isWakeupEnable = config?.wakeupMode == WakeupMode.on;
    _mAudioRecording = false;
    _wakeUpText = wakeUpText;

    if (config != null)
      _configHandler = AIUIConfigHandler(config);
    else if (path != null) _configHandler = AIUIConfigHandler.fromAssets(path);

    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case AIUIChannel.ERROR:
          _callback(
              _listener?.onError,
              AIUIError(
                  code: call.arguments?['errorCode'],
                  message: call.arguments?['errorMessage']));
          break;
        case AIUIChannel.EVENT:
          _processEvent(call.arguments);
          break;
      }
    });

    await _channel.invokeMethod(AIUIChannel.INIT, {
      'config': jsonEncode(_configHandler.config),
      "wakeUpText": _wakeUpText,
      'autoPlay': true,
      'isWakeUpEnable': _isWakeupEnable
    });
  }

  ///
  /// 开始语音识别
  ///
  /// [config] 语音识别参数
  ///
  Future<void> startSpeak({IatConfig? config}) async {
    if (_mAudioRecording == true) return;

    final error = await _channel.invokeMethod(
        AIUIChannel.START_SPEAK, config?.toString());
    if (error != null && _listener?.onError != null) {
      _listener!.onError!(error);
    } else {
      _mAudioStart = DateTime.now().millisecond;
      if (_mAppendVoiceMsg != null) {
        // if (_listener?.onIatResult != null) {
        //   _listener!.onIatResult!(_mAppendVoiceMsg!);
        // }
        _mAppendVoiceMsg = null;
        _mInterResultStack.clear();
      }

      //清空PGS听写中间结果
      for (int index = 0; index < _mIATPGSStack.length; index++) {
        _mIATPGSStack[index] = null;
      }

      _mAppendVoiceMsg = RawMessage(
        fromType: FromType.USER,
        msgType: MsgType.Voice,
        msgData: 0,
        cacheContent: '',
      );

      _mAudioRecording = true;
    }
  }

  /// 结束录音识别
  Future<void> stopSpeak() async {
    if (_mAudioRecording == false) return;
    if (_mAppendVoiceMsg != null) {
      _mAppendVoiceMsg?.msgData = DateTime.now().millisecond - _mAudioStart;
      _callback(_listener?.onIatResult, _mAppendVoiceMsg!);
    }
    await _channel.invokeMethod(AIUIChannel.END_SPEAK);
    _mAudioRecording = false;
  }

  ///
  /// 开始语音播报
  ///
  /// [config] 语音播报参数
  /// [text] 文字
  ///
  Future<void> startTts({TtsConfig? config, String? text, bool resume = false}) async {
    if (text == null) return;
    await _channel.invokeMethod(AIUIChannel.START_TTS,
        {'config': config?.toString() ?? TtsConfig().toString(), 'text': text, 'resume': resume});
  }

  ///
  /// 结束录音播报
  ///
  Future<void> stopTts() async {
    await _channel.invokeMethod(AIUIChannel.STOP_TTS);
  }

  /// 修改语音播报方式
  Future<void> changeTtsPlayMode(PlayMode playMode) async {
    _configHandler.changePlayMode(playMode);
    _channel.invokeMethod(AIUIChannel.INIT, {
      'config': jsonEncode(_configHandler.config),
      "wakeUpText": _wakeUpText,
      'autoPlay': true,
      'isWakeUpEnable': _isWakeupEnable
    });
  }

  /// 设置参数
  Future<void> setParams(String params) async {
    await _channel.invokeMethod(AIUIChannel.SET_PARAM, params);
  }

  ///
  /// 查询指定音频内容
  ///
  Future<void> syncQuery(String sid) async {
    await _channel.invokeMethod(AIUIChannel.SYNC_QUERY, sid);
  }

  ///
  /// 开始文字识别
  ///
  /// [config] 语音识别参数
  /// [text] 需要识别的文字
  ///
  Future<void> writeText({String? text, IatConfig? config}) async {
    if (text == null || text.isEmpty) {
      return;
    }
    assert(config == null || config.dataType == DataType.text);
    await _channel.invokeMethod(AIUIChannel.WRITE_TEXT, {
      "text": text,
      "config":
          config?.toString() ?? IatConfig(dataType: DataType.text).toString()
    });
  }

  ///
  /// 销毁
  ///
  Future<void> dispose() async {
    await _channel.invokeMethod('dispose');

    clearListener();
  }

  /// 用完记得释放listener
  void clearListener() {
    _channel.setMethodCallHandler(null);
  }

  /// 处理AIUI事件
  /// [arguments] AIUI事件信息
  void _processEvent(arguments) {
    try {
      AIUIEvent _event = AIUIEvent.fromJson(arguments);
      switch (_event.eventType) {
        case AIUIConstant.EVENT_RESULT:
          _processResult(_event);
          break;
        case AIUIConstant.EVENT_VAD:
          _processVADEvent(_event);
          break;

        case AIUIConstant.EVENT_ERROR:
          _processError(_event);
          break;

        case AIUIConstant.EVENT_WAKEUP:
          //唤醒添加语音消息
          if (_isWakeupEnable) {
            //唤醒自动停止播放
            stopTts();
            startSpeak();
          }
          break;

        case AIUIConstant.EVENT_SLEEP:
          //休眠结束语音
          if (_isWakeupEnable) {
            stopSpeak();
          }
          break;

        case AIUIConstant.EVENT_CONNECTED_TO_SERVER:
          _callback(_listener?.onServerConnected);
          break;

        case AIUIConstant.EVENT_SERVER_DISCONNECTED:
          _callback(_listener?.onServerDisConnected);
          break;

        case AIUIConstant.EVENT_START_RECORD:
          _callback(_listener?.onRecordStarted);
          break;

        case AIUIConstant.EVENT_STOP_RECORD:
          _callback(_listener?.onRecordEnded);
          break;

        case AIUIConstant.EVENT_STATE:
          _callback(_listener?.onStateChanged, _event.arg1);
          break;

        case AIUIConstant.EVENT_TTS:
          _processTts(_event);
          break;
      }
    } catch (e) {
      print(e);
    }
  }

  /// 处理TTS结果
  /// [event] TTS事件
  void _processTts(AIUIEvent event) {
    switch (event.arg1) {
      case AIUIConstant.TTS_SPEAK_COMPLETED:
        _callback(_listener?.onTTSEnded);
        break;
      case AIUIConstant.TTS_SPEAK_BEGIN:
        _callback(_listener?.onTTSStarted);
        break;
      case AIUIConstant.TTS_SPEAK_PAUSED:
        _callback(_listener?.onTTSPaused);
        break;
    }
  }

  /// 处理AIUI结果
  /// [event] AIUI结果事件
  void _processResult(AIUIEvent event) {
    Map<String, dynamic> bizParam = jsonDecode(event.info!);
    Map<String, dynamic> eventData = jsonDecode(event.data!);
    Map<String, dynamic> bizData = bizParam['data']?.first;
    Map<String, dynamic> params = bizData['params'];
    Map<String, dynamic> content = bizData['content']?.first;
    int repTime = eventData['eos_rslt'] ?? -1;
    String sub = params['sub'];
    String? cntId = content['cnt_id'];
    if (cntId != null && sub != 'tts') {
      try {
        Uint8List bytes = Uint8List.fromList(eventData[cntId]?.cast<int>());
        Map<String, dynamic> cntParam = jsonDecode(utf8.decode(bytes));
        if (sub == 'nlp') {
          Map<String, dynamic>? semanticResult = cntParam['intent'];
          if (semanticResult != null && semanticResult.isNotEmpty) {
            //解析得到语义结果，将语义结果作为消息插入到消息列表中
            RawMessage rawMessage = RawMessage(
                fromType: FromType.AIUI,
                msgType: MsgType.TEXT,
                msgData: semanticResult,
                responseTime: repTime);
            _callback(_listener!.onIatResult, rawMessage);
            _callback(
                _listener!.onNlpResult, AIUIResult.fromJson(semanticResult));
          }
        } else if (sub == "iat") {
          _processIATResult(cntParam);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  /// 解析听写结果更新当前语音消息的听写内容
  /// [cntParam] 听写结果
  void _processIATResult(Map<String, dynamic> cntParam) {
    if (_mAppendVoiceMsg == null) return;

    Map<String, dynamic> text = cntParam['text'];
    // 解析拼接此次结果
    String iatText = '';
    List words = text['ws'];
    bool lastResult = text['ls'];
    for (int index = 0; index < words.length; index++) {
      List charWords = words[index]['cw'];
      for (int cIndex = 0; cIndex < charWords.length; cIndex++) {
        iatText = '$iatText${charWords[cIndex]['w']}';
      }
    }

    String voiceIAT = '';
    String pgsMode = text['pgs'] ?? '';
    //非PGS模式结果
    if (pgsMode.isEmpty) {
      if (iatText.isEmpty) return;
      // 和上一次结果拼接
      if (_mAppendVoiceMsg?.cacheContent?.isNotEmpty == true) {
        voiceIAT = _mAppendVoiceMsg!.cacheContent!;
      }
      voiceIAT = '$voiceIAT$iatText';
    }
    else {
      try {
        int serialNumber = text['sn'];
        _mIATPGSStack[serialNumber] = iatText.toString();
        // pgs结果两种模式rpl和apd模式（替换与追加模式）
        if (pgsMode == 'rpl') {
          // 根据replace指定的range，清空stack中对应位置值
          List replaceRange = text['rg'];
          int start = replaceRange[0];
          int end = replaceRange[1];

          for (int index = start; index <= end; index++) {
            _mIATPGSStack[index] = null;
          }
        }

        String pgsResult = '';
        // 汇总stack经过操作后的剩余的有效结果信息
        for (int index = 0; index < _mIATPGSStack.length; index++) {
          if (_mIATPGSStack[index] == null || _mIATPGSStack[index]!.isEmpty)
            continue;
          pgsResult = pgsResult + _mIATPGSStack[index]!;
          //如果是最后一条听写结果，则清空stack便于下次使用
          if (lastResult == true) _mIATPGSStack[index] = null;
        }
        voiceIAT = _mInterResultStack.join('') + pgsResult;

        if (lastResult == true) _mInterResultStack.add(pgsResult);
      } catch (e) {
        print(e);
      }
    }

    if (voiceIAT.isNotEmpty) {
      _mAppendVoiceMsg!.cacheContent = voiceIAT;
      _mAppendVoiceMsg!.responseTime = DateTime.now().microsecondsSinceEpoch;
      _callback(_listener!.onIatResult, _mAppendVoiceMsg!);
    }
  }

  /// 错误处理
  ///
  /// 在聊天对话消息中添加错误消息提示
  /// [aiuiEvent] 错误事件
  void _processError(AIUIEvent aiuiEvent) {
    //向消息列表中添加AIUI错误消息
    int errorCode = aiuiEvent.arg1!;
    String errorMessage = '';
    //AIUI网络异常，不影响交互，可以作为排查问题的线索和依据
    if (errorCode >= 10200 && errorCode <= 10215) {
      errorMessage = 'AIUI网络警告，可忽略';
      return;
    }

    switch (errorCode) {
      case 10120:
        {
          errorMessage = '网络有点问题：${aiuiEvent.info}';
          break;
        }

      case 20006:
        {
          errorMessage = '录音启动失败:请检查是否有其他应用占用录音${aiuiEvent.info}';
          break;
        }

      default:
        {
          errorMessage = '${aiuiEvent.arg1}错误${aiuiEvent.info}';
        }
    }

    _callback<Function, AIUIError>(
        _listener!.onError, AIUIError(code: errorCode, message: errorMessage));
  }

  /// 处理vad事件，音量更新
  /// @param aiuiEvent
  void _processVADEvent(AIUIEvent aiuiEvent) {
    if (aiuiEvent.eventType == AIUIConstant.EVENT_VAD) {
      if (aiuiEvent.arg1 == AIUIConstant.VAD_VOL) {
        _callback(_listener?.onVolumeChanged, aiuiEvent.arg2);
      }
    }
  }

  void _callback<F, T>(F? func, [T? param]) {
    if (func != null) {
      if (func is Function)
        func(param);
      else if (func is VoidCallback) func();
    }
  }
}
