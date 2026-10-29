import 'package:flutter/material.dart';

/// 纸面色板。每个预设对应一套完整的中性色，避免出现"黄底"。
class Palette {
  final String key;
  final String name;
  final String swatch; // 只有颜色预设按钮用，值为 hex
  final Color paper;
  final Color card;
  final Color line;
  final Color ink;
  final Color ink2;
  final Color muted;
  final bool dark;

  const Palette({
    required this.key,
    required this.name,
    required this.swatch,
    required this.paper,
    required this.card,
    required this.line,
    required this.ink,
    required this.ink2,
    required this.muted,
    this.dark = false,
  });

  /// 给纯色按钮使用的 Color
  Color get swatchColor => parseHex(swatch);
}

Color parseHex(String hex) {
  var h = hex.replaceAll('#', '');
  if (h.length == 6) h = 'FF$h';
  return Color(int.parse(h, radix: 16));
}

const List<Palette> kPalettes = <Palette>[
  Palette(
    key: 'clear',
    name: '清透白',
    swatch: '#ffffff',
    paper: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    line: Color(0xFFE6E9EE),
    ink: Color(0xFF1B1E23),
    ink2: Color(0xFF555B65),
    muted: Color(0xFF8A919C),
  ),
  Palette(
    key: 'cool',
    name: '冷灰',
    swatch: '#f3f5f8',
    paper: Color(0xFFF3F5F8),
    card: Color(0xFFFFFFFF),
    line: Color(0xFFE0E4EA),
    ink: Color(0xFF1B1E23),
    ink2: Color(0xFF555B65),
    muted: Color(0xFF8A919C),
  ),
  Palette(
    key: 'slate',
    name: '石板蓝',
    swatch: '#eaeef4',
    paper: Color(0xFFEAEEF4),
    card: Color(0xFFF7F9FC),
    line: Color(0xFFD7DEE8),
    ink: Color(0xFF1C2430),
    ink2: Color(0xFF4F5A6B),
    muted: Color(0xFF8290A3),
  ),
  Palette(
    key: 'mint',
    name: '淡青',
    swatch: '#ecf2ef',
    paper: Color(0xFFECF2EF),
    card: Color(0xFFF7FBF9),
    line: Color(0xFFD8E3DE),
    ink: Color(0xFF1D2422),
    ink2: Color(0xFF54615C),
    muted: Color(0xFF879690),
  ),
  Palette(
    key: 'lav',
    name: '淡紫',
    swatch: '#f0edf7',
    paper: Color(0xFFF0EDF7),
    card: Color(0xFFF9F7FD),
    line: Color(0xFFDED8EC),
    ink: Color(0xFF221E2B),
    ink2: Color(0xFF5A5468),
    muted: Color(0xFF8F89A0),
  ),
  Palette(
    key: 'warm',
    name: '米白',
    swatch: '#faf7f2',
    paper: Color(0xFFFAF7F2),
    card: Color(0xFFFFFDF9),
    line: Color(0xFFE8E1D6),
    ink: Color(0xFF211E1A),
    ink2: Color(0xFF5B554D),
    muted: Color(0xFF948D83),
  ),
  Palette(
    key: 'paper',
    name: '纸黄',
    swatch: '#f6efe0',
    paper: Color(0xFFF6EFE0),
    card: Color(0xFFFBF6EA),
    line: Color(0xFFDED2B9),
    ink: Color(0xFF2C2519),
    ink2: Color(0xFF665C49),
    muted: Color(0xFF9A8F79),
  ),
  Palette(
    key: 'night',
    name: '夜间',
    swatch: '#12151a',
    paper: Color(0xFF12151A),
    card: Color(0xFF1B1F25),
    line: Color(0xFF282D34),
    ink: Color(0xFFE8E3DC),
    ink2: Color(0xFFB3AAA1),
    muted: Color(0xFF7D858F),
    dark: true,
  ),
];

/// 强调色预设，默认是 AO3 的经典红
class AccentPreset {
  final String key;
  final String name;
  final String hex;
  const AccentPreset(this.key, this.name, this.hex);
}

const List<AccentPreset> kAccents = <AccentPreset>[
  AccentPreset('crimson', '绯红', '#9c1f26'),
  AccentPreset('plum', '绛紫', '#6d4a8c'),
  AccentPreset('indigo', '深靛', '#24608a'),
  AccentPreset('pine', '松绿', '#2f6b52'),
  AccentPreset('ochre', '赭石', '#8a5a2b'),
  AccentPreset('graphite', '石墨', '#3a3f47'),
];

/// 把颜色向白色/黑色混合，用于夜间自动提亮强调色
Color mixColor(Color a, Color b, double t) {
  return Color.lerp(a, b, t)!;
}

Palette paletteByKey(String key) {
  return kPalettes.firstWhere(
    (p) => p.key == key,
    orElse: () => kPalettes.first,
  );
}
