/// 翻译结果
class ITransResult {
  const ITransResult({
    required this.from,
    required this.ret,
    required this.sid,
    required this.to,
    required this.transResult,
  });

  factory ITransResult.fromJson(Map json) => ITransResult(
        from: json['from'],
        ret: json['ret'],
        sid: json['sid'],
        to: json['to'],
        transResult: TransResult.fromJson(json['trans_result']),
      );

  /// 源语种
  final String from;
  final int ret;
  final String sid;

  /// 翻译语种
  final String to;

  /// 翻译结果
  final TransResult transResult;
}

class TransResult {
  const TransResult({required this.src, required this.dst});

  factory TransResult.fromJson(Map json) =>
      TransResult(src: json['src'], dst: json['dst']);

  /// 源语言结果
  final String src;

  /// 翻译结果
  final String dst;
}
