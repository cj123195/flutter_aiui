/// 动态修正结果追加方式
enum Pgs {
  /// 该片结果是追加到前面的最终结果
  apd,

  /// 替换前面的部分结果
  rpl;

  static Pgs? tryParse(String? value) {
    for (Pgs pgs in Pgs.values) {
      if (value == pgs.name) {
        return pgs;
      }
    }
    return null;
  }
}

/// 语音识别结果
class IatResult {
  IatResult({
    required this.sentence,
    required this.lastSentence,
    required this.begin,
    required this.end,
    required this.words,
    this.pgs,
    this.rg,
  });

  factory IatResult.fromJson(Map json) {
    List<Words> words;
    if (json['ws'] == null || json['ws'] is! List) {
      words = [];
    } else {
      words = (json['ws'] as List).cast<Map>().map(Words.fromJson).toList();
    }

    List<int>? rg;
    Pgs? pgs;
    if (json['pgs'] != null) {
      pgs = Pgs.tryParse(json['pgs']);
      if (json['rg'] is List) {
        rg = (json['rg'] as List).cast<int>();
      }
    }

    return IatResult(
      sentence: json['sn'] ?? 0,
      lastSentence: json['ls'] ?? false,
      begin: json['bg'] ?? 0,
      end: json['ed'] ?? 0,
      words: words,
      pgs: pgs,
      rg: rg,
    );
  }

  /// 第几句
  final int sentence;

  /// 是否最后一句
  final bool lastSentence;

  /// 保留字段，无需关注
  final int begin;

  /// 保留字段，无需关注
  final int end;

  /// 词
  final List<Words> words;

  /// 开启wpgs会有此字段
  ///
  /// 取值为 "apd"时表示该片结果是追加到前面的最终结果；取值为"rpl" 时表示替换前面的部分结果，
  /// 替换范围为rg字段
  final Pgs? pgs;

  final List<int>? rg;

  String get text {
    String result = '';
    for (int i = 0; i < words.length; i++) {
      // 转写结果词，默认使用第一个结果
      if (words[i].chineseWords.isNotEmpty) {
        result = '$result${words[i].chineseWords.first.word}';
      }
//				如果需要多候选结果，解析数组其他字段
//				for(int j = 0; j < items.length(); j++)
//				{
//					JSONObject obj = items.getJSONObject(j);
//					ret.append(obj.getString("w"));
//				}
    }
    return result;
  }
}

/// 词
class Words {
  Words(this.begin, this.chineseWords);

  factory Words.fromJson(Map json) {
    List<ChineseWord> words;
    if (json['cw'] == null || json['cw'] is! List) {
      words = [];
    } else {
      words =
          (json['cw'] as List).cast<Map>().map(ChineseWord.fromJson).toList();
    }
    return Words(json['bg'] ?? 0, words);
  }

  /// 保留字段，无需关注
  final int begin;
  final List<ChineseWord> chineseWords;
}

class ChineseWord {
  ChineseWord(this.score, this.word);

  factory ChineseWord.fromJson(Map json) =>
      ChineseWord(json['sc'] ?? 0.0, json['w'] ?? '');

  /// 分数
  final int score;

  /// 单字
  final String word;
}
