import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_aiui/flutter_aiui.dart';
import 'package:flutter_aiui_example/wave.dart';

/// AIUI平台上应用ID
const String appId = 'xxxxxxx';

void main() {
  runApp(const MyApp());
}

enum FromType { user, aiui }

enum MsgType { text, voice }

class RawMessage<T> {
  RawMessage({
    required this.fromType,
    required this.msgType,
    required this.msgData,
    this.msgVersion = 0,
    this.cacheContent = '',
    this.responseTime,
  }) {
    msgID = sMsgIDStore++;
  }

  static int sMsgIDStore = 0;

  late int msgID;
  int msgVersion;
  int? responseTime;
  FromType fromType;
  MsgType msgType;
  String cacheContent;
  T msgData;

  void versionUpdate() {
    msgVersion++;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: VoiceAssistantView());
  }
}

/// 语音助手页面
class VoiceAssistantView extends StatefulWidget {
  const VoiceAssistantView({super.key});

  @override
  State<VoiceAssistantView> createState() => _VoiceAssistantViewState();
}

class _VoiceAssistantViewState extends State<VoiceAssistantView> {
  late ScrollController _controller;

  final AiuiParams _params = AiuiParams(
    appId: appId,
    global: GlobalParams(scene: 'main_box'),
    speech: SpeechParams(wakeupMode: WakeupMode.vtn),
  );

  /// 是否开启唤醒模式
  bool get _wakeUpEnabled => _params.speech.wakeupMode == WakeupMode.vtn;

  /// 是否已唤醒
  bool _isWakeup = false;

  /// 是否正在录音
  bool _isRecording = false;

  /// 当前未结束的语音交互消息，更新语音消息的听写内容时使用
  RawMessage? _appendVoiceMsg;

  /// 当前消息列表
  final List<RawMessage> _interactMsg = [];

  /// 处理PGS听写(流式听写）的数组
  final List<String?> _iATPGSStack = List.filled(256, null);

  final List<String> _interResultStack = [];

  DateTime _audioStartTime = DateTime.now();

  /// 切换唤醒模式
  Future<void> _switchWakeupMode(bool value) async {
    if (value) {
      _params.speech.wakeupMode = WakeupMode.vtn;
      await FlutterAiui().initAgent(_params);
    } else {
      _params.speech.wakeupMode = WakeupMode.off;
      await FlutterAiui().initAgent(_params);
    }

    setState(() {});
  }

  /// 更新消息
  void _updateMessage(RawMessage message) {
    message.versionUpdate();
    setState(() {});
  }

  /// 添加消息
  void _addMessage(RawMessage rawMessage) {
    _interactMsg.add(rawMessage);
    setState(() {});
  }

  /// 文本识别
  Future<void> _writeText(String text) async {
    await FlutterAiui().stopTTS();

    if (_appendVoiceMsg != null) {
      _interResultStack.clear();
      _appendVoiceMsg = null;
    }

    await FlutterAiui().writeText(text);

    _addMessage(
      RawMessage<String>(
        fromType: FromType.user,
        msgType: MsgType.text,
        msgData: text,
      ),
    );

    setState(() {});
  }

  /// 开始说话
  Future<void> _startSpeak() async {
    await FlutterAiui().stopTTS();

    if (!_isRecording) {
      await FlutterAiui().startRecordAudio();
      _isRecording = true;
    }

    if (!_wakeUpEnabled) {
      _beginAudio();
    }

    setState(() {});
  }

  /// 开始录音
  void _beginAudio() {
    _audioStartTime = DateTime.now();
    if (_appendVoiceMsg != null) {
      //更新上一条未完成的语音消息内容
      _updateMessage(_appendVoiceMsg!);
      _appendVoiceMsg = null;
      _interResultStack.clear();
    }

    for (int index = 0; index < _iATPGSStack.length; index++) {
      _iATPGSStack[index] = null;
    }

    _appendVoiceMsg = RawMessage<int>(
      fromType: FromType.user,
      msgType: MsgType.voice,
      msgData: 0,
    );
    _addMessage(_appendVoiceMsg!);
  }

  /// 停止说话
  Future<void> _endSpeak() async {
    if (_isRecording) {
      await FlutterAiui().stopRecordAudio();
      _isRecording = false;
    }

    if (!_wakeUpEnabled) {
      _endAudio();
    }

    setState(() {});
  }

  /// 停止录音
  void _endAudio() {
    if (_appendVoiceMsg != null) {
      final Duration diff = DateTime.now().difference(_audioStartTime);
      _appendVoiceMsg!.msgData = diff.inSeconds;
      _updateMessage(_appendVoiceMsg!);
    }
  }

  /// 解析听写结果更新当前语音消息的听写内容
  void _processIatResult(IatResult result, int responseTime) {
    final Pgs? pgs = result.pgs;

    String voiceIAT = '';
    if (pgs == null) {
      if (result.text.isEmpty) {
        return;
      }
      if (_appendVoiceMsg?.cacheContent.isNotEmpty == true) {
        voiceIAT = _appendVoiceMsg!.cacheContent;
      }
      voiceIAT += result.text;
    } else {
      _iATPGSStack[result.sentence] = result.text;
      //pgs结果两种模式rpl和apd模式（替换和追加模式）
      if (pgs == Pgs.rpl) {
        final int start = result.rg![0];
        final int end = result.rg![1];
        for (int index = start; index <= end; index++) {
          _iATPGSStack[index] = null;
        }
      }

      //汇总stack经过操作后的剩余的有效结果信息
      String pgsResult = '';
      for (int index = 0; index < _iATPGSStack.length; index++) {
        if (_iATPGSStack[index]?.isNotEmpty != true) {
          continue;
        }

        pgsResult += _iATPGSStack[index]!;
        //如果是最后一条听写结果，则清空stack便于下次使用
        if (result.lastSentence) {
          _iATPGSStack[index] = null;
        }
      }

      voiceIAT =
          _interResultStack.fold('', (pre, text) => pre + text) + pgsResult;

      if (result.lastSentence) {
        _interResultStack.add(pgsResult);
      }
    }

    if (voiceIAT.isNotEmpty) {
      _appendVoiceMsg!.cacheContent = voiceIAT;
      _appendVoiceMsg!.responseTime = responseTime;
      _updateMessage(_appendVoiceMsg!);
    }
  }

  /// 解析语义理解数据
  void _processNlpResult(NlpResult result, int responseTime) {
    /// 拒识（rc = 4）结果处理
    if (result.rc == Rc.cannotHandle && result.answer == null) {
      const String text = '你好，我不懂你的意思\n\n在后台添加更多技能让我变得更聪明吧';
      result.answer ??= const Answer(text: text);
      FlutterAiui().startTTS(text);
    }
    final RawMessage rawMessage = RawMessage<NlpResult>(
      fromType: FromType.aiui,
      msgType: MsgType.text,
      msgData: result,
      responseTime: responseTime,
    );
    _addMessage(rawMessage);
  }

  /// 处理错误
  void _onError(int errorCode, String errorMessage) {
    String message;

    //AIUI网络异常，不影响交互，可以作为排查问题的线索和依据
    if (errorCode >= 10200 && errorCode <= 10215) {
      debugPrint('AIUI Error: $errorCode');
      return;
    }

    switch (errorCode) {
      case 10120:
        message = '网络有点问题 :(，请检查你的网络';
        break;
      case 11200:
        message = '11200 错误 \n小娟发音人权限未开启，请在控制台应用配置下启用语音合成后等待一分钟生效后再重启应用';
        break;
      case 20006:
        message = '录音启动失败 :(，请检查是否有其他应用占用录音';
        break;
      case 600002:
        message = '唤醒 600002 错误\n 唤醒配置vtn.ini路径错误，请检查配置路径';
        break;
      case 600100:
        message = '唤醒 600100 错误\n 唤醒资源文件路径错误，请检查资源路径';
        break;
      case 600022:
        message = '唤醒 600022 错误\n 唤醒装机授权不足，请联系商务开通';
        break;
      default:
        message = '$errorCode 错误：$errorMessage';
        break;
    }
    final RawMessage rawMessage = RawMessage<String>(
      fromType: FromType.aiui,
      msgType: MsgType.text,
      msgData: message,
    );
    _addMessage(rawMessage);
  }

  /// 唤醒回调
  void _onWakeup(WakeupType type, String? message) {
    debugPrint('AIUI Wakeup');
    if (_wakeUpEnabled) {
      //唤醒自动停止播放
      FlutterAiui().stopTTS();

      _beginAudio();

      setState(() {
        _isWakeup = true;
      });
    }
  }

  /// 唤醒回调
  void _onSleep(SleepType type) {
    debugPrint('AIUI Sleep');

    //休眠结束语音
    if (_isWakeup) {
      _endAudio();
      setState(() {
        _isWakeup = false;
      });
    }
  }

  Future<void> _init() async {
    await FlutterAiui().initAgent(_params);
    FlutterAiui().addListener(
      AiuiEventListener(
        onError: _onError,
        onVad: (event, [volume]) => debugPrint('Vad event：$event'),
        onIatResult: _processIatResult,
        onNlpResult: _processNlpResult,
        onRecordStart: () {
          setState(() {
            _isRecording = true;
          });
        },
        onRecordStop: () {
          setState(() {
            _isRecording = false;
          });
        },
        onWakeup: _onWakeup,
        onSleep: _onSleep,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    FlutterAiui().destroyAgent();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 50), () {
      _controller.animateTo(
        _controller.position.maxScrollExtent - 20,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    });

    final Widget list = ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemBuilder: (context, index) =>
          _DialogueItem(message: _interactMsg[index]),
      controller: _controller,
      physics: const BouncingScrollPhysics(),
      itemCount: _interactMsg.length,
    );

    final Widget bottom = _wakeUpEnabled
        ? Container(
            color: Theme.of(context).colorScheme.surfaceTint.withOpacity(0.05),
            height: 48.0,
            width: double.infinity,
            child: _isWakeup
                ? const Wave(
                    configs: [
                      WaveConfig(
                        amplitudes: 15,
                        frequency: 2,
                        gradients: [
                          Colors.white,
                          Colors.white54,
                        ],
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      '快说小矿小矿唤醒我吧',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
          )
        : _ActionBar(_writeText, _startSpeak, _endSpeak);

    return Scaffold(
      appBar: AppBar(title: const Text('AIUI Demo')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: Drawer(
        child: SafeArea(
          child: SwitchListTile(
            title: const Text('唤醒模式'),
            value: _wakeUpEnabled,
            onChanged: _switchWakeupMode,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Expanded(child: list), bottom],
      ),
    );
  }
}

enum DialogueType { question, answer, line, bar, pie, table }

/// 语音助手会话框组件
class _DialogueItem extends StatelessWidget {
  const _DialogueItem({required this.message});

  final RawMessage message;

  static const EdgeInsetsGeometry padding =
      EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0);
  static const BorderRadius userBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(8.0),
    topRight: Radius.circular(8.0),
    bottomLeft: Radius.circular(8.0),
  );

  @override
  Widget build(BuildContext context) {
    if (message.fromType == FromType.user) {
      if (message.msgType == MsgType.text) {
        return _buildQuestion(context);
      }
      return _buildVoice(Theme.of(context).colorScheme);
    }
    return _buildResultText(context);
  }

  /// 问题
  Widget _buildQuestion(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final TextStyle? textStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: scheme.onPrimary);

    return Align(
      alignment: Alignment.centerRight,
      child: Card(
        shape: const RoundedRectangleBorder(borderRadius: userBorderRadius),
        color: scheme.primary,
        child: Padding(
          padding: padding,
          child: Text(message.msgData, style: textStyle),
        ),
      ),
    );
  }

  /// 语音
  Widget _buildVoice(ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerRight,
      child: Card(
        color: colorScheme.primary,
        shape: const RoundedRectangleBorder(borderRadius: userBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.volume_up_rounded,
                    color: colorScheme.outline,
                    size: 18,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '${message.msgData}s',
                    style: TextStyle(color: colorScheme.outline, fontSize: 12),
                  ),
                ],
              ),
              if (message.cacheContent.isNotEmpty)
                Text(
                  message.cacheContent,
                  style: TextStyle(color: colorScheme.onPrimary),
                )
            ],
          ),
        ),
      ),
    );
  }

  /// 文字类型结果
  Widget _buildResultText(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color color = theme.colorScheme.surface;
    const BorderRadius borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(8.0),
      topRight: Radius.circular(8.0),
      bottomRight: Radius.circular(8.0),
    );
    final TextStyle? textStyle = theme.textTheme.bodyLarge;
    const ShapeBorder shape =
        RoundedRectangleBorder(borderRadius: borderRadius);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(radius: 20, child: Icon(Icons.face)),
        const SizedBox(width: 8.0),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Card(
              shape: shape,
              color: color,
              child: Padding(
                padding: padding,
                child: Text(
                  message.msgData is String
                      ? message.msgData
                      : (message.msgData as NlpResult).answer!.text,
                  style: textStyle,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

/// 操作栏
class _ActionBar extends StatefulWidget {
  const _ActionBar(this.onSearch, this.onSpeakTapDown, this.onSpeakTapUp);

  final ValueChanged<String> onSearch;
  final VoidCallback onSpeakTapDown;
  final VoidCallback onSpeakTapUp;

  @override
  State<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<_ActionBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _editingController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _editingController.dispose();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [Expanded(child: _buildTextField()), _buildRecordButton()],
      ),
    );
  }

  /// 输入框
  Widget _buildTextField() {
    const InputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(100)),
      borderSide: BorderSide(width: 1.5),
    );

    final Widget button = AnimatedOpacity(
      opacity: _editingController.text.isEmpty ? 0 : 1,
      duration: const Duration(milliseconds: 100),
      child: IconButton(
        onPressed: () {
          if (_editingController.text.isNotEmpty) {
            widget.onSearch(_editingController.text);
            // _editingController.clear();
          }
        },
        icon: const Icon(Icons.send),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 8.0),
      child: TextField(
        onChanged: (val) {
          if (mounted) {
            setState(() {});
          }
        },
        focusNode: _focusNode,
        controller: _editingController,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          hintText: '输入你想要搜索的内容',
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          suffixIcon: button,
        ),
      ),
    );
  }

  /// 录音按钮
  Widget _buildRecordButton() {
    final ColorScheme theme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (TapDownDetails detail) => widget.onSpeakTapDown(),
      onTapUp: (TapUpDetails detail) => widget.onSpeakTapUp(),
      onTapCancel: widget.onSpeakTapUp,
      child: Material(
        shape: const CircleBorder(),
        color: theme.inverseSurface,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            Icons.settings_voice_outlined,
            color: theme.onInverseSurface,
          ),
        ),
      ),
    );
  }
}
