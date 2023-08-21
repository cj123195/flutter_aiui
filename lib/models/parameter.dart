import 'package:flutter_aiui/constant.dart';

bool _isNull(key, value) {
  return value == null;
}

/// 引擎类型
enum EngineType {
  /// 本地引擎
  local,

  /// 云端引擎
  cloud
}

/// Tts引擎类型
enum TtsEngineType { aisound, xtts }

/// 录音数据来源
enum DataSource {
  /// 外部录音
  user,

  /// sdk内部录音
  sdk
}

/// 交互模式
enum InteractMode {
  /// 对于语音即“一次唤醒，一次交互”
  oneshot,

  /// 持续交互，对于语音即“一次唤醒，多次交互”
  continuous
}

/// 资源类型
enum ResType {
  /// apk工程的assets文件
  assets,

  /// apk工程的res文件
  res,

  /// sdcard文件
  path
}

/// 音频播放模式
enum PlayMode {
  /// 内部播放
  user,

  /// 用户自行播放
  sdk
}

/// 唤醒模式
enum WakeupMode {
  /// 关闭唤醒模式
  off,

  /// 唤醒词唤醒
  vtn
}

/// Iat数据类型
enum DataType {
  /// 音频
  audio('audio-tag'),

  /// 文本
  text('text-tag');
  // image // 暂不支持

  const DataType(this.tag);

  final String tag;
}

/// AIUI参数
class AiuiParams {
  /// 新建AIUI参数
  AiuiParams({
    required this.appId,
    this.userParams,
    GlobalParams? global,
    InteractParams? interact,
    VadParams? vad,
    IatParams? iat,
    AudioParams? audioParams,
    RecorderParams? recorder,
    IvwParams? ivw,
    SpeechParams? speech,
    TtsParams? tts,
    LogParams? log,
  })  : global = global ?? GlobalParams(),
        interact = interact ?? InteractParams(),
        vad = vad ?? VadParams(),
        iat = iat ?? IatAudioParams(),
        audioParams = audioParams ?? AudioParams(),
        recorder = recorder ?? RecorderParams(),
        ivw = ivw ?? IvwParams(),
        speech = speech ?? SpeechParams(),
        tts = tts ?? TtsParams(),
        log = log ?? LogParams();

  /// 在讯飞开放平台上注册的8位应用唯一标识。
  String appId;

  // 用户参数，透传到后处理(非必须)
  late final Map<String, String?>? userParams;

  /// 全局设置
  GlobalParams global;

  /// 交互设置
  InteractParams interact;

  /// 本地vad参数
  VadParams vad;

  /// Iat语音识别相关配置
  IatParams iat;

  /// 音频参数
  AudioParams audioParams;

  /// 录音器参数
  RecorderParams recorder;

  /// 语音唤醒参数
  IvwParams ivw;

  /// 语音业务流程控制参数
  SpeechParams speech;

  // tts语音合成相关配置
  TtsParams tts;

  /// 日志设置
  LogParams log;

  Map<String, Map?>? toMap() {
    final Map<String, String> login = {
      AiuiConstant.keyAppId: appId,
    };

    final Map<String, Map?> config = {
      AiuiConstant.keyLogin: login,
      AiuiConstant.keyUserParams: userParams,
      AiuiConstant.keyGlobal: global.toMap(),
      AiuiConstant.keyInteract: interact.toMap(),
      AiuiConstant.keyVad: vad.toMap(),
      AiuiConstant.keyIat: iat.toMap(),
      AiuiConstant.keyAudioParams: audioParams.toMap(),
      AiuiConstant.keyRecorder: recorder.toMap(),
      AiuiConstant.keyIvw: ivw.toMap(),
      AiuiConstant.keySpeech: speech.toMap(),
      AiuiConstant.keyTts: tts.toCfgMap(),
      AiuiConstant.keyLog: log.toMap(),
    };
    for (var conf in config.values) {
      conf?.removeWhere(_isNull);
    }
    config.removeWhere((key, value) => value == null || value.isEmpty);
    return config;
  }
}

/// 清除历史模式
enum CleanDialogHistory {
  /// 自动清除历史
  auto,

  /// 用户手动清除历史
  user
}

/// 全局设置
class GlobalParams {
  GlobalParams({this.scene, this.cleanDialogHistory = CleanDialogHistory.auto});

  /// 用户定制的场景参数，不同的场景可对应不同的云端处理流程。
  String? scene;

  /// 清除交互历史设置
  /// [CleanDialogHistory.auto] 自动清除历史
  /// [CleanDialogHistory.user] 用户手动清除历史
  ///
  /// 默认值为[CleanDialogHistory.auto]
  CleanDialogHistory cleanDialogHistory;

  Map<String, String?> toMap() => {
        AiuiConstant.keyScene: scene,
        AiuiConstant.keyCleanDialogHistory: cleanDialogHistory.name,
      };
}

/// 交互参数
class InteractParams {
  InteractParams({this.interactTimeout = -1, this.resultTimeout = 5000})
      : assert(
          interactTimeout == -1 ||
              (interactTimeout >= 10000 && interactTimeout < 180000),
        );

  /// 交互超时(单位：ms)
  ///
  /// 即唤醒之后，如果在这段时间内无有效交互则重新进入待唤醒状态，取值：[10000,180000)。
  /// 默认为1min。
  int interactTimeout;

  /// 结果超时（单位：ms）
  ///
  /// 即检测到语音后端点后一段时间内无结果返回则抛出10120错误码。
  /// 默认值：5000。
  int? resultTimeout;

  Map<String, String?> toMap() => {
        AiuiConstant.keyInteractTimeout: interactTimeout.toString(),
        AiuiConstant.keyResultTimeout: resultTimeout?.toString()
      };
}

/// 本地vad参数
class VadParams {
  VadParams({
    this.vadEnable = true,
    this.engineType = 'evad',
    this.resType = ResType.assets,
    this.resPath = 'vad/evad_16k.jet',
    this.vadEos = 600,
    this.vadBos,
    this.cloudVadEos,
    this.cloudVadGap,
  }) : assert(vadEnable == false || (resPath != null && resType != null));

  /// 启用vad
  ///
  /// 默认值：true。
  bool? vadEnable;

  /// vad引擎类型
  ///
  /// 默认值：meta。
  String? engineType;

  /// 资源文件路径
  ///
  /// 使用模型vad时必须设置。
  String? resPath;

  /// 资源类型
  ///
  /// 使用模型vad时必须设置，取值：
  /// [ResType.assets] apk工程的assets文件
  /// [ResType.res] apk工程的res文件
  /// [ResType.path] sdcard文件
  ResType? resType;

  /// VAD后端超时时间
  ///
  /// 单位：毫秒
  int? vadEos;

  /// VAD前端超时时间
  ///
  /// 单位：毫秒
  int? vadBos;

  /// 云端VAD后端超时时间
  ///
  /// 单位：毫秒
  int? cloudVadEos;

  /// 云端VAD分句间隔
  //
  /// 单位：毫秒，上限值：1800
  int? cloudVadGap;

  Map<String, String?> toMap() => {
        AiuiConstant.keyVadEnable: vadEnable == false ? '0' : '1',
        AiuiConstant.keyEngineType: engineType,
        AiuiConstant.keyResType: resType?.name,
        AiuiConstant.keyResPath: resPath,
        AiuiConstant.keyVadEos: vadEos?.toString(),
        AiuiConstant.keyVadBos: vadBos?.toString(),
        AiuiConstant.keyCloudVadEos: cloudVadEos?.toString(),
        AiuiConstant.keyCloudVadGap: cloudVadGap?.toString(),
      };
}

/// 识别（音频输入）参数
abstract class IatParams {
  IatParams({
    required this.dataType,
    this.tag,
  });

  /// 参数类型
  ///
  /// [DataType.audio] 音频
  /// [DataType.text] 文本
  ///
  /// 默认值为[DataType.audio]
  DataType dataType;

  /// 识别标记
  String? tag;

  Map<String, dynamic> toMap();
}

/// 音频语义理解参数
class IatAudioParams extends IatParams {
  IatAudioParams({
    this.sampleRate = 16000,
    this.dwa = 'wpgs',
    super.tag,
  }) : super(dataType: DataType.audio);

  /// 采样率
  ///
  /// 默认值为16000
  int? sampleRate;

  /// 流式识别配置
  ///
  /// 默认值为wpgs
  String? dwa;

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> param = {
      AiuiConstant.keyDataType: dataType.name,
      AiuiConstant.keyTag: tag ?? dataType.tag,
      AiuiConstant.keySampleRate: sampleRate,
      AiuiConstant.keyDwa: dwa,
    };

    param.removeWhere(_isNull);
    return param;
  }
}

/// 文字语义理解参数
class IatTextParams extends IatParams {
  IatTextParams({super.tag}) : super(dataType: DataType.text);

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> param = {
      AiuiConstant.keyDataType: dataType.name,
      AiuiConstant.keyTag: tag ?? dataType.tag,
    };

    param.removeWhere(_isNull);
    return param;
  }
}

/// 音频参数
class AudioParams {
  AudioParams({this.ttsResType, this.persParam});

  /// 经度
  double? mscLng;

  /// 纬度
  double? mscLat;

  /// 语义后合成下发mp3链接
  String? ttsResType;

  /// 其他参数
  String? persParam;

  Map<String, String?> toMap() => {
        AiuiConstant.keyMscLng: mscLng?.toString(),
        AiuiConstant.keyMscLat: mscLat?.toString(),
        AiuiConstant.keyTtsResType: ttsResType,
        AiuiConstant.keyPersParam: persParam,
      };
}

/// 录音器参数
class RecorderParams {
  RecorderParams({
    this.channelCount = 1,
    this.channelFilter = '0,-1',
  });

  /// 录音通道个数
  ///
  /// 默认值为1
  int? channelCount;

  /// 录音通道过滤
  ///
  /// 默认值为0,-1
  String? channelFilter;

  Map<String, String?> toMap() => {
        AiuiConstant.keyChannelCount: channelCount?.toString(),
        AiuiConstant.keyChannelFilter: channelFilter,
      };
}

/// 语音唤醒参数
class IvwParams {
  IvwParams({
    this.micType = 'mic1',
    this.resPath = '/sdcard/AIUI/ivw/vtn/vtn.ini',
    this.resType = ResType.path,
  });

  /// 麦克风类型
  ///
  /// 默认值为mic1
  String? micType;

  /// ivw资源类型
  ResType? resType;

  /// ivw资源文件路径
  ///
  /// 非必要不修改，否则会导致资源识别不到
  String? resPath;

  Map<String, String?> toMap() => {
        AiuiConstant.keyMicType: micType,
        AiuiConstant.keyResType: resType?.name,
        AiuiConstant.keyResPath: resPath,
      };
}

/// 语音业务流程控制参数
class SpeechParams {
  SpeechParams({
    this.dataSource = DataSource.sdk,
    this.interactMode = InteractMode.oneshot,
    this.wakeupMode = WakeupMode.off,
    this.intentEngineType,
  });

  /// 录音数据来源配置
  /// [DataSource.sdk] sdk内部录音
  /// [DataSource.user] 外部录音
  DataSource dataSource;

  /// 交互模式设置
  ///
  /// [InteractMode.continuous] 持续交互，对于语音即“一次唤醒，多次交互”
  /// [InteractMode.oneshot]一次交互，对于语音即“一次唤醒，一次交互”
  ///
  /// 默认值为[InteractMode.oneshot]
  ///
  /// oneshot举例：
  ///
  /// 问：叮咚叮咚，给我唱首歌（说完后AIUI即进入休眠状态）
  /// 答：请欣赏xxxx。
  /// 后续AIUI因已休眠不能继续交互,需重新唤醒才能继续交互。
  InteractMode interactMode;

  /// 唤醒模式设置
  ///
  /// [WakeupMode.off] 关闭唤醒模式
  /// [WakeupMode.vtn] 使用唤醒词唤醒
  ///
  /// 默认值为[WakeupMode.off]
  WakeupMode wakeupMode;

  /// 引擎设置
  ///
  /// [EngineType.local] 本地引擎
  /// [EngineType.cloud] 云端引擎
  ///
  /// 默认值为[EngineType.cloud]
  EngineType? intentEngineType;

  Map<String, String?> toMap() => {
        AiuiConstant.keyDataSource: dataSource.name,
        AiuiConstant.keyWakeupMode: wakeupMode.name,
        AiuiConstant.keyIntentEngineType: intentEngineType?.name,
        AiuiConstant.keyInteractMode: interactMode.name
      };
}

/// 语音合成参数
class TtsParams {
  TtsParams({
    this.vcn = 'x2_xiaojuan',
    this.speed = 50,
    this.pitch = 50,
    this.volume = 50,
    this.streamType = 3,
    this.ent = TtsEngineType.xtts,
    this.bufferTime = 0,
    this.playMode = PlayMode.sdk,
    this.audioFocus = false,
  });

  // 发音人
  String? vcn;

  /// 语速
  ///
  /// 默认值为50
  int? speed;

  /// 语调
  ///
  /// 默认值为50
  int? pitch;

  /// 音量
  ///
  /// 默认值为50
  int? volume;

  /// 引擎类型
  TtsEngineType ent;

  // cfg设置
  /// 播放模式
  ///
  /// [PlayMode.sdk] 内部播放
  /// [PlayMode.user] 用户自行播放
  ///
  /// 默认值为[PlayMode.sdk]
  PlayMode playMode;

  /// 音频缓冲时长
  ///
  /// 当缓冲音频大于该值时才开始播放。
  ///
  /// 默认值：0ms
  int? bufferTime;

  /// 播放音频流类型，取值参考AudioManager类，默认值：3
  int? streamType;

  /// 播放音频时是否抢占焦点
  ///
  /// 默认值为false
  bool? audioFocus;

  /// 合成标记
  String? tag;

  Map<String, dynamic> toMap() {
    final Map<String, String> param = {
      AiuiConstant.keyVcn: vcn.toString(),
      AiuiConstant.keySpeed: speed.toString(),
      AiuiConstant.keyVolume: volume.toString(),
      AiuiConstant.keyPitch: pitch.toString(),
      AiuiConstant.keyEnt: ent.name,
      AiuiConstant.keyTag: tag ?? '@${DateTime.now().millisecond}'
    };

    param.removeWhere(_isNull);
    return param;
  }

  Map<String, dynamic> toCfgMap() {
    final Map<String, dynamic> param = {
      AiuiConstant.keyPlayMode: playMode.name,
      AiuiConstant.keyBufferTime: bufferTime,
      AiuiConstant.keyStreamType: streamType,
      AiuiConstant.keyAudioFocus: audioFocus == true ? '1' : '0',
    };

    param.removeWhere(_isNull);
    return param;
  }

  @override
  String toString() {
    final List<String> textList = <String>[];
    toMap().keys.forEach((key) {
      textList.add('$key=${toMap()[key]}');
    });
    return textList.join(',');
  }
}

/// 日志设置
class LogParams {
  LogParams({
    this.debugLog = false,
    this.saveDataLog = false,
    this.dataLogPath,
    this.dataLogSize = 1024,
    this.rawAudioPath,
  });

  /// Debug日志开关
  ///
  /// 日志打开时会向logcat打印调试日志。
  ///
  /// 默认值为false
  bool? debugLog;

  /// 是否保存数据日志
  ///
  /// 打开之后会将所有上传到云端的音频和云端返回的结果保存到本地，保存的路径位于/sdcard/AIUI/data/，
  /// 每一次唤醒后的交互音频都保存在此目录下wakeXX开始的文件夹下。
  ///
  /// 默认值为false
  bool? saveDataLog;

  /// 数据日志的保存路径
  ///
  /// 当不设置或者为空值时，使用默认值：“/sdcard/AIUI/data/”。
  String? dataLogPath;

  /// 数据日志的大小限制（单位：MB）
  ///
  /// 取值：[-1，+∞)
  /// 默认值：-1（表示无大小限制）。
  /// 注意：设置成-1可能会造成SD卡被日志写满，从而导致AIUI性能下降，影响体验效果。
  int? dataLogSize;

  /// 音频保存地址
  String? rawAudioPath;

  Map<String, String?> toMap() => {
        AiuiConstant.keyDebugLog: debugLog == true ? '1' : '0',
        AiuiConstant.keySaveDatalog: saveDataLog == true ? '1' : '0',
        AiuiConstant.keyDatalogPath: dataLogPath,
        AiuiConstant.keyDatalogSize: dataLogSize?.toString(),
        AiuiConstant.keyRawAudioPath: rawAudioPath
      };
}
