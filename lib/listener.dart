import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aiui/models/event.dart';
import 'package:flutter_aiui/models/i_trans_result.dart';
import 'package:flutter_aiui/models/tts_result.dart';

import 'models/iat_result.dart';
import 'models/nlp_result.dart';

/// 唤醒类型
enum WakeupType {
  /// 内部语音唤醒
  sdk,

  /// 外部手动唤醒（外部发送CMD_WAKEUP）。
  user;

  static WakeupType parse(int value) {
    for (WakeupType type in WakeupType.values) {
      if (type.index == value) {
        return type;
      }
    }
    return WakeupType.user;
  }
}

/// 休眠类型
enum SleepType {
  /// 自动休眠，即交互超时
  auto,

  /// 外部强制休眠，即发送CMD_RESET_WAKEUP
  compel;

  static SleepType parse(int value) {
    for (SleepType type in SleepType.values) {
      if (type.index == value) {
        return type;
      }
    }
    return SleepType.compel;
  }
}

/// VAD事件类型
enum VadEventType {
  /// 前端点
  bos,

  /// 后端点
  eos,

  /// 音量
  volume,

  /// 前端点超时
  bosTimeout;

  static VadEventType parse(int value) {
    for (VadEventType type in VadEventType.values) {
      if (type.index == value) {
        return type;
      }
    }
    return VadEventType.bos;
  }
}

/// 讯飞语音识别的回调映射，有flutter来决定处理所有的回调结果，
/// 会更具有灵活性
class AiuiEventListener {
  AiuiEventListener({
    this.onResult,
    this.onIatResult,
    this.onNlpResult,
    this.onTppResult,
    this.onTtsResult,
    this.onITransResult,
    this.onError,
    this.onStateChange,
    this.onWakeup,
    this.onSleep,
    this.onVad,
    this.onCmdReturn,
    this.onPreSleep,
    this.onRecordStart,
    this.onRecordStop,
    this.onConnectedToServer,
    this.onServerDisconnected,
    this.onTts,
  });

  /// 原始结果事件
  ///
  /// Aiui插件会处理结果并将结果通过相应回调返回，但是有时开发者可能需要让用户选择需要执行的
  /// 操作，那么此回调就是将原始结果返回开发者以处理数据。
  final void Function(AiuiEvent event)? onResult;

  /// 听写结果事件
  final void Function(IatResult result, int responseTime)? onIatResult;

  /// 语义结果事件
  final void Function(NlpResult result, int responseTime)? onNlpResult;

  /// 后处理服务结果事件
  final void Function(AiuiEvent event)? onTppResult;

  /// 云端tts结果事件
  final void Function(TtsResult result)? onTtsResult;

  /// 翻译结果事件
  final void Function(ITransResult result)? onITransResult;

  /// 出错事件
  final void Function(int errorCode, String message)? onError;

  /// 状态变更事件
  final void Function(int stateCode)? onStateChange;

  /// 唤醒事件
  final void Function(WakeupType type, String? message)? onWakeup;

  /// 休眠事件
  final void Function(SleepType type)? onSleep;

  /// VAD事件
  final void Function(VadEventType type, [int? volume])? onVad;

  /// 某条CMD命令对应的返回事件
  ///
  /// 对于除CMD_GET_STATE外的有返回的命令，都会返回该事件，
  /// 用arg1标识对应的CMD命令，arg2为返回值，0表示成功，info字段为描述信息。
  final void Function(int cmd, int result, String? message)? onCmdReturn;

  /// 准备休眠事件
  ///
  /// 当出现交互超时，服务会先抛出准备休眠事件，用户可在接收到该事件后的10s内继续交互。
  /// 若10s内存在有效交互，则重新开始交互计时；若10s内不存在有效交互，则10s后进入休眠状态。
  final VoidCallback? onPreSleep;

  /// 抛出该事件通知外部录音开始，用户可以开始说话
  final VoidCallback? onRecordStart;

  /// 通知外部录音停止
  final VoidCallback? onRecordStop;

  /// 与服务端建立起连接事件
  final VoidCallback? onConnectedToServer;

  /// 与服务端断开连接事件
  final VoidCallback? onServerDisconnected;

  /// 语音合成事件
  final VoidCallback? onTts;
}
