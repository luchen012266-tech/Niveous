/// 演示用数据模型。
///
/// 正式版这里会换成 AO3 抓取层：把 HTML 解析成同样的数据结构塞进来，
/// UI 层完全不用改。见 data/work_repository.dart。
library;

class Para {
  final String en;
  final String zh;
  const Para(this.en, this.zh);
}

class Chapter {
  final String title;
  final List<Para> paragraphs;
  const Chapter(this.title, this.paragraphs);
}

class Work {
  final int id;
  final String title;
  final String titleZh;
  final String author;
  final String fandom;
  final String rating; // G / T / M / E
  final List<String> warnings;
  final String relationship;
  final List<String> tags;
  final List<String> tagsZh;
  final String summary;
  final String summaryZh;
  final String words;
  final int year;
  final String kudos;
  final String hits;
  final bool complete;
  final bool zhReady;
  final List<Chapter> chapters;

  const Work({
    required this.id,
    required this.title,
    required this.titleZh,
    required this.author,
    required this.fandom,
    required this.rating,
    required this.warnings,
    required this.relationship,
    required this.tags,
    required this.tagsZh,
    required this.summary,
    required this.summaryZh,
    required this.words,
    required this.year,
    required this.kudos,
    required this.hits,
    required this.complete,
    required this.zhReady,
    required this.chapters,
  });

  String get displayTitle => titleZh.isEmpty ? title : titleZh;
  bool get hasZhTitle => titleZh.isNotEmpty && titleZh != title;
  int get chapterCount => chapters.length;
}

/// AO3 分级对应的颜色
const Map<String, int> kRatingColors = <String, int>{
  'G': 0xFF2E7D32,
  'T': 0xFFE0930C,
  'M': 0xFFE2661A,
  'E': 0xFFB3261E,
};
