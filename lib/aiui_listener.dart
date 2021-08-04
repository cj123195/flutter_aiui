import 'package:flutter/material.dart';

import 'aiui.dart';


/// 讯飞语音识别的回调映射，有flutter来决定处理所有的回调结果，
/// 会更具有灵活性
class AIUIEventListener {
  VoidCallback? onAgentCreated;
  VoidCallback? onAgentDestroyed;
  VoidCallback? onServerConnected;
  VoidCallback? onServerDisConnected;
  VoidCallback? onWakeUp;
  VoidCallback? onSleep;
  VoidCallback? onTextNlpStart;
  VoidCallback? onRecordEnded;
  VoidCallback? onRecordStarted;
  VoidCallback? onTTSStarted;
  VoidCallback? onTTSEnded;
  VoidCallback? onTTSPaused;

  void Function(AIUIResult result)? onNlpResult;
  void Function(RawMessage result)? onIatResult;
  void Function(int volume)? onVolumeChanged;
  void Function(int state)? onStateChanged;
  void Function(AIUIError error)? onError;

  AIUIEventListener(
      {this.onAgentCreated,
      this.onAgentDestroyed,
      this.onServerConnected,
      this.onServerDisConnected,
      this.onWakeUp,
      this.onSleep,
      this.onTextNlpStart,
      this.onRecordEnded,
      this.onRecordStarted,
      this.onTTSStarted,
      this.onTTSEnded,
      this.onTTSPaused,
      this.onNlpResult,
      this.onIatResult,
      this.onVolumeChanged,
      this.onStateChanged,
      this.onError});
}
