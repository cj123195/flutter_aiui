import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_aiui/aiui.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  String voiceMsg = '暂无数据';

  AIUIResult? result;

  @override
  void initState() {
    super.initState();
    connect();
  }

  /// 建立Socket连接
  Future<void> connect() async {
    final String id = Uuid().v4();

    try {
      final channel = IOWebSocketChannel.connect(
          'ws://222.187.101.140:8011/ws-iflyos?key=$id');
      print(id);
      channel.sink.add('$id!');

      channel.stream.listen((message) {
        print(message);
      });
      initPlatformState(id);
    } catch (e) {
      print(e);
    }
  }

  Future<void> initPlatformState(String socketId) async {
    print(socketId);
    final voice = FlutterAIUI.shared;
    AIUIEventListener? listen = AIUIEventListener(
        onVolumeChanged: (volume) {},
        onRecordStarted: () {
          result = null;
        },
        onNlpResult: (re) {
          // if (re.service != 'OS9205522566.xiaoyun_mobile')
          //   AIUIPlugin.shared.startTts(param: TtsParam(), text: re.text);
          setState(() {
            result = re;
          });
        },
        onError: (e) {
          print('111');
        });
    voice.init(
        config: AIUIConfig(
          appId: "4839503e",
          userParams: {'socketId': socketId},
        ),
        listener: listen,
        // iosParam: AIUIParam(appId: "604eaf8f", resPath: "meta_vad_16k.jet"),
        wakeUpText: "小矿小矿");
  }

  @override
  void dispose() {
    FlutterAIUI.shared.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '测试的demo',
      home: Scaffold(
          appBar: AppBar(
            title: new Text('测试demo'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (result != null) Text(result?.text ?? ''),
                if (result?.data != null && result?.service == 'weather')
                  Image.network(
                    (result?.data[0] as AIUIWeather).img!,
                    width: 300,
                    height: 300,
                  ),
                GestureDetector(
                  child: Container(
                    child: Text(result?.text ?? "按住说话"),
                    width: 300.0,
                    height: 50.0,
                    color: Colors.blueAccent,
                  ),
                  onTapDown: (d) {
                    setState(() {
                      voiceMsg = '按下';
                    });
                    _recongize();
                  },
                  onTapUp: (d) {
                    _recongizeOver();
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    FlutterAIUI.shared.writeText(
                      text: '今天天气怎么样',
                    );
                  },
                  child: Text('文字识别'),
                )
              ],
            ),
          )),
    );
  }

  void _recongize() {
    FlutterAIUI.shared.startSpeak();
  }

  void _recongizeOver() {
    FlutterAIUI.shared.stopSpeak();
  }
}
