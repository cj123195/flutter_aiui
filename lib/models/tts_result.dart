import 'dart:typed_data';

/// 音频块位置状态
enum TtsDts {
  /// 合成音频开始块
  start,

  /// 合成音频中间块，可出现多次
  middle,

  /// 合成音频结束块
  end,

  /// 合成音频独立块,在短合成文本时出现
  independence;

  static TtsDts parse(int dts) {
    for (TtsDts ttsDts in TtsDts.values) {
      if (ttsDts.index == dts) {
        return ttsDts;
      }
    }
    return TtsDts.independence;
  }
}

/// 音频结果
class TtsResult {
  TtsResult({
    required this.dts,
    required this.frameId,
    required this.isCancel,
    required this.audioData,
    this.percent = 0,
  });

  /// 音频块位置状态信息
  ///
  /// 举例说明：
  /// 一个正常语音合成可能对应的块顺序如下：
  ///   0 1 1 1 ... 2
  /// 一个短的语音合成可能对应的块顺序如下:
  ///   3
  final TtsDts dts;

  /// 音频段id，取值：1,2,3,...
  final int frameId;

  /// 合成进度
  final int percent;

  /// 合成过程中是否被取消
  final bool isCancel;

  /// 合成音频数据
  final Uint8List audioData;
}
