import 'package:flutter/material.dart';

/// 一个可排版的最小单位：一段正文 / 一个标题 / 一行说明。
///
/// 只存「内容 + 类型」，颜色和字体在渲染时按当前主题现算 ——
/// 这样切换深色/纸色不需要重新分页（高度只由字号、行距决定）。
class ReaderBlock {
  final String text;

  /// head | meta | en | zh
  final String kind;
  final double spaceAfter;

  const ReaderBlock(this.text, this.kind, {this.spaceAfter = 16});
}

/// 纯静态分页：用 TextPainter 量出每块高度，再按页面高度装箱。
/// 换字号 / 行距 / 屏幕尺寸 / 字体，都会重新算一次（重排后回到原来的比例位置）。
class Paginator {
  static List<List<ReaderBlock>> paginate({
    required List<ReaderBlock> blocks,
    required double width,
    required double height,
    required TextStyle Function(String kind) styleOf,
  }) {
    final List<List<ReaderBlock>> pages = <List<ReaderBlock>>[];
    List<ReaderBlock> current = <ReaderBlock>[];
    double used = 0;

    for (final ReaderBlock b in blocks) {
      final TextPainter tp = TextPainter(
        text: TextSpan(text: b.text, style: styleOf(b.kind)),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width);
      final double h = tp.height + b.spaceAfter;

      if (current.isNotEmpty && used + h > height) {
        pages.add(current);
        current = <ReaderBlock>[];
        used = 0;
      }
      current.add(b);
      used += h;
    }
    if (current.isNotEmpty) pages.add(current);
    if (pages.isEmpty) pages.add(<ReaderBlock>[]);
    return pages;
  }
}
