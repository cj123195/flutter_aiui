/// 引擎类型
enum EngineType { local, cloud }

/// Tts引擎类型
enum TtsEngineType { aisound, xtts }

/// 资源类型
enum DataSource { user, sdk }

/// 交互模式
enum InteractMode { oneshot, continuous }

/// 清除历史模式
enum CleanDialogHistory { auto, user }

/// 资源文件路径
enum ResType { assets, res, path }

/// 音频播放方式
enum PlayMode { user, sdk }

/// 是否开启唤醒模式
enum WakeupMode { off, on }

/// Iat数据类型
enum DataType {
  audio,
  text,
  image // 暂不支持
}

class IatConfig {
  DataType? dataType;
  int? sampleRate;
  double? lat;
  double? lng;
  Map<String, dynamic>? recUserData;

  IatConfig(
      {this.dataType = DataType.audio,
      this.sampleRate = 16000,
      this.lat,
      this.lng,
      this.recUserData});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> param = {
      'data_type': this.dataType == DataType.text ? "text" : "audio",
      "tag": this.dataType == DataType.text ? "text-tag" : "audio-tag",
      'sample_rate': this.sampleRate,
      'msc.lng': this.lng,
      'msc.lat': this.lat,
      'rec_user_data': this.recUserData,
    };
    final isNull = (key, value) {
      return value == null;
    };
    param.removeWhere(isNull);
    return param;
  }

  String toString() {
    List<String> texts = <String>[];
    this.toMap().keys.forEach((key) {
      texts.add("$key=${this.toMap()[key]}");
    });
    return texts.join(",");
  }
}

class TtsConfig {
  // tts设置
  String? vcn; // 发音人
  String? speed; // 语速;
  String? pitch; // 语调
  String? volume; // 音量
  TtsEngineType? ent; // 引擎

  // cfg设置
  PlayMode? playMode;
  int? bufferTime;

  /// Android平台中AudioTrack类型
  /// 通话:0, 系统:1, 铃声:2, 音乐:3, 闹铃:4, 通知:5
  String streamType;
  bool audioFocus;

  TtsConfig(
      {this.vcn = 'x2_xiaojuan',
      this.speed = '50',
      this.pitch = '50',
      this.volume = '50',
      this.streamType = '3',
      this.ent = TtsEngineType.xtts,
      this.bufferTime = 0,
      this.playMode = PlayMode.sdk,
      this.audioFocus = false});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> param = {
      'vcn': this.vcn,
      'speed': this.speed,
      'volume': this.volume,
      'pitch': this.pitch,
      'ent': this.ent == TtsEngineType.aisound ? "aisound" : "xtts",
    };
    final isNull = (key, value) {
      return value == null;
    };
    param.removeWhere(isNull);
    return param;
  }

  Map<String, dynamic> toCfgMap() {
    Map<String, dynamic> param = {
      'play_mode': playMode == PlayMode.sdk ? 'sdk' : 'user',
      'buffer_time': this.bufferTime,
      'stream_type': this.streamType,
      'audio_focus': this.audioFocus == true ? "1" : "0",
    };
    final isNull = (key, value) {
      return value == null;
    };
    param.removeWhere(isNull);
    return param;
  }

  String toString() {
    List<String> textList = <String>[];
    this.toMap().keys.forEach((key) {
      textList.add("$key=${this.toMap()[key]}");
    });
    return textList.join(",");
  }
}

class AIUIConfig {
  // login
  String appId; // 应用ID

  // 用户参数，透传到后处理(非必须)
  late final Map<String, dynamic>? userParams;

  // audioParams
  Map<String, String>? audioParams;
  double? lng;
  double? lat;

  // interact
  int interactTimeout; // 交互超时时间
  int? resultTimeout; // 响应超时时间

  // global
  String? scene; // 场景
  CleanDialogHistory? cleanDialogHistory; // 是否自动清除会话历史

  // vad
  bool? vadEnable; // 是否启用本地vad
  final String? engineType = "meta"; // vad引擎类型
  String? resPath; // 资源文件路径
  ResType? resType; // 资源类型
  int? vadEos; // VAD前端超时时间
  int? vadBos; // VAD后端超时时间
  int? cloudVadEos; //  云端VAD后端超时时间
  int? cloudVadGap; // 云端VAD分句间隔

  // speech
  DataSource? dataSource; // 录音数据来源配置
  InteractMode? interactMode; // 交互模式设置
  WakeupMode? wakeupMode; // 是否开启唤醒模式
  EngineType? intentEngineType; // 引擎

  // log
  bool? debugLog; // Debug日志开关
  bool? saveDataLog; // 是否保存数据日志
  String? dataLogPath; // 数据日志的保存路径
  int? dataLogSize; // 数据日志的大小限制（单位：MB）
  String? rawAudioPath; // 音频保存地址

  // iat
  IatConfig? iatConfig; // Iat语音识别相关参数

  // tts
  TtsConfig? ttsConfig; // Tts语音合成相关参数

  AIUIConfig(
      {required this.appId,
      this.interactTimeout = -1,
      this.resultTimeout = 5000,
      this.scene = 'main_box',
      this.cleanDialogHistory = CleanDialogHistory.auto,
      this.vadEnable = true,
      this.resType = ResType.assets,
      this.resPath = "vad/meta_vad_16k.jet",
      this.vadEos = 60000,
      this.vadBos,
      this.cloudVadEos,
      this.cloudVadGap = 1800,
      this.dataSource = DataSource.sdk,
      this.interactMode = InteractMode.oneshot,
      this.wakeupMode = WakeupMode.off,
      this.intentEngineType = EngineType.cloud,
      this.debugLog = false,
      this.saveDataLog = false,
      this.dataLogPath,
      this.dataLogSize,
      this.userParams,
      TtsConfig? ttsConfig,
      IatConfig? iatConfig,
      this.rawAudioPath})
      : this.ttsConfig = ttsConfig ?? TtsConfig(),
        this.iatConfig = iatConfig ?? IatConfig(),
        assert(interactTimeout == -1 ||
            (interactTimeout >= 10000 && interactTimeout < 18000));

  Map<String, Map?>? toMap() {
    Map<String, String> login = {
      "appid": this.appId,
    };
    Map<String, String?> interact = {
      "interact_timeout": this.interactTimeout.toString(),
      "result_timeout": this.resultTimeout?.toString()
    };
    Map<String, String?> global = {
      "scene": this.scene,
      "clean_dialog_history":
          this.cleanDialogHistory == CleanDialogHistory.user ? "user" : "auto"
    };
    Map<String, String?> vad = {
      "vad_enable": this.vadEnable == false ? "0" : "1",
      "engine_type": this.engineType,
      "res_type": this.resType == ResType.res
          ? "res"
          : this.resType == ResType.path
              ? "path"
              : "assets",
      "res_path": this.resPath,
      "vad_eos": this.vadEos?.toString(),
      // "vad_bos": this.vadBos?.toString(),
      // "cloud_vad_eos": this.cloudVadEos?.toString(),
      // "cloud_vad_gap": this.cloudVadGap?.toString(),
    };
    Map<String, String> speech = {
      "data_source": this.dataSource == DataSource.user ? "user" : "sdk",
      "wakeup_mode": this.wakeupMode == WakeupMode.on ? "on" : "off",
      // "intent_engine_type":
      //     this.intentEngineType == EngineType.local ? "local" : "cloud",
      "interact_mode": this.interactMode == InteractMode.continuous
          ? "continuous"
          : "oneshot"
    };
    Map<String, dynamic> log = {
      "debug_log": this.debugLog == false ? "0" : "1",
      "save_datalog": this.saveDataLog == true ? "1" : "0",
      "datalog_path": this.dataLogPath ?? "",
      "datalog_size": this.dataLogSize ?? 1024,
      "raw_audio_path": this.rawAudioPath ?? ""
    };
    Map<String, dynamic> audioParams = this.audioParams ?? {};
    audioParams["msc.lng"] = this.lng;
    audioParams["msc.lat"] = this.lat;

    final isNull = (key, value) {
      return value == null;
    };
    interact.removeWhere(isNull);
    global.removeWhere(isNull);
    vad.removeWhere(isNull);
    speech.removeWhere(isNull);
    log.removeWhere(isNull);
    Map<String, Map?> config = {
      "login": login,
      "interact": interact,
      "global": global,
      "vad": vad,
      "audioparams": audioParams,
      "speech": speech,
      "iat": this.iatConfig?.toMap(),
      "tts": this.ttsConfig?.toCfgMap(),
      "userparams": userParams
    };
    config.removeWhere(isNull);
    return config;
  }
}
