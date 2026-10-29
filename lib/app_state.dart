import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'palettes.dart';

/// 用一个 InheritedNotifier 把全局状态发给所有页面（避免引入额外状态管理依赖）
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required Widget child,
  }) : super(notifier: state, child: child);

  static AppState of(BuildContext context) {
    final AppScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope 没有挂在 widget 树上');
    return scope!.notifier!;
  }
}

/// 用户自己导入的字体
class CustomFont {
  final String family; // 运行时注册用的 family 名
  final String name; // 显示名（文件名去掉后缀）
  final String path; // 本地文件绝对路径
  final int bytes;

  const CustomFont({
    required this.family,
    required this.name,
    required this.path,
    required this.bytes,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'family': family,
        'name': name,
        'path': path,
        'bytes': bytes,
      };

  static CustomFont fromJson(Map<String, dynamic> m) => CustomFont(
        family: m['family'] as String? ?? '',
        name: m['name'] as String? ?? '字体',
        path: m['path'] as String? ?? '',
        bytes: (m['bytes'] as num?)?.toInt() ?? 0,
      );
}

/// 全局状态。所有设置都存在手机本地（SharedPreferences + 应用私有目录）。
class AppState extends ChangeNotifier {
  // ---------- 外观 ----------
  String paperKey = 'clear';
  String accentHex = '#9c1f26';

  // ---------- 字体 ----------
  String fontKey = 'serif'; // sans | serif | round | custom:<family>
  String fontScope = 'all'; // all | body
  List<CustomFont> customFonts = <CustomFont>[];

  // ---------- 阅读 ----------
  String readerMode = 'scroll'; // scroll | paged
  String flipMode = 'tap'; // tap | swipe
  double fontSize = 18;
  double lineHeight = 1.85;
  bool translate = false;
  String translateDisplay = 'dual'; // dual | zh

  // ---------- 背景图 ----------
  bool bgEnabled = true;
  String? bgPath = 'asset:assets/bg/rain.jpg';
  double opApp = 0.30;
  double opRd = 0.30;
  double plate = 0.55;
  double blur = 2;
  double hue = 0;
  double sat = 1;
  double bri = 1;
  bool applyApp = true;
  bool applyRd = true;

  // ---------- 账号 ----------
  bool authed = false; // 本次会话已进入 App（含访客）
  bool loggedIn = false; // 真的登录了 AO3 账号
  String userName = 'wandered_off';
  Set<int> bookmarks = <int>{3};

  // ---------- 运行时 ----------
  SharedPreferences? _prefs;
  static const String _root = 'ao3reader';

  // ==========================================================
  // 加载 / 保存
  // ==========================================================
  static Future<AppState> load() async {
    final AppState s = AppState();
    final SharedPreferences p = await SharedPreferences.getInstance();
    s._prefs = p;

    s.paperKey = p.getString('$_root.paper') ?? s.paperKey;
    s.accentHex = p.getString('$_root.accent') ?? s.accentHex;
    s.fontKey = p.getString('$_root.fontKey') ?? s.fontKey;
    s.fontScope = p.getString('$_root.fontScope') ?? s.fontScope;
    s.readerMode = p.getString('$_root.readerMode') ?? s.readerMode;
    s.flipMode = p.getString('$_root.flipMode') ?? s.flipMode;
    s.fontSize = p.getDouble('$_root.fontSize') ?? s.fontSize;
    s.lineHeight = p.getDouble('$_root.lineHeight') ?? s.lineHeight;
    s.translate = p.getBool('$_root.translate') ?? s.translate;
    s.translateDisplay = p.getString('$_root.translateDisplay') ?? s.translateDisplay;

    s.bgEnabled = p.getBool('$_root.bgEnabled') ?? s.bgEnabled;
    s.bgPath = p.getString('$_root.bgPath');
    s.opApp = p.getDouble('$_root.opApp') ?? s.opApp;
    s.opRd = p.getDouble('$_root.opRd') ?? s.opRd;
    s.plate = p.getDouble('$_root.plate') ?? s.plate;
    s.blur = p.getDouble('$_root.blur') ?? s.blur;
    s.hue = p.getDouble('$_root.hue') ?? s.hue;
    s.sat = p.getDouble('$_root.sat') ?? s.sat;
    s.bri = p.getDouble('$_root.bri') ?? s.bri;
    s.applyApp = p.getBool('$_root.applyApp') ?? s.applyApp;
    s.applyRd = p.getBool('$_root.applyRd') ?? s.applyRd;

    s.authed = p.getBool('$_root.authed') ?? s.authed;
    s.loggedIn = p.getBool('$_root.loggedIn') ?? s.loggedIn;
    s.userName = p.getString('$_root.userName') ?? s.userName;
    final String? bm = p.getString('$_root.bookmarks');
    if (bm != null && bm.isNotEmpty) {
      s.bookmarks = bm
          .split(',')
          .map((String e) => int.tryParse(e) ?? -1)
          .where((int e) => e > 0)
          .toSet();
    }

    final String? fontsJson = p.getString('$_root.customFonts');
    if (fontsJson != null && fontsJson.isNotEmpty) {
      s.customFonts = decodeFonts(fontsJson);
    }
    // 自定义字体是运行时注册的，重启后必须重新注册一次
    await s._reloadFonts();
    return s;
  }

  /// 极简 JSON 编解码（避免额外依赖 convert 之外的包）
  static List<CustomFont> decodeFonts(String raw) {
    final List<CustomFont> out = <CustomFont>[];
    // 用 \u0001 分隔字段、\u0002 分隔条目，简单可靠
    for (final String row in raw.split('\u0002')) {
      if (row.isEmpty) continue;
      final List<String> f = row.split('\u0001');
      if (f.length < 4) continue;
      out.add(CustomFont(
        family: f[0],
        name: f[1],
        path: f[2],
        bytes: int.tryParse(f[3]) ?? 0,
      ));
    }
    return out;
  }

  static String encodeFonts(List<CustomFont> fonts) {
    return fonts
        .map((CustomFont f) => '${f.family}\u0001${f.name}\u0001${f.path}\u0001${f.bytes}')
        .join('\u0002');
  }

  Future<void> persist() async {
    final SharedPreferences p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    await p.setString('$_root.paper', paperKey);
    await p.setString('$_root.accent', accentHex);
    await p.setString('$_root.fontKey', fontKey);
    await p.setString('$_root.fontScope', fontScope);
    await p.setString('$_root.readerMode', readerMode);
    await p.setString('$_root.flipMode', flipMode);
    await p.setDouble('$_root.fontSize', fontSize);
    await p.setDouble('$_root.lineHeight', lineHeight);
    await p.setBool('$_root.translate', translate);
    await p.setString('$_root.translateDisplay', translateDisplay);

    await p.setBool('$_root.bgEnabled', bgEnabled);
    if (bgPath != null) await p.setString('$_root.bgPath', bgPath!);
    await p.setDouble('$_root.opApp', opApp);
    await p.setDouble('$_root.opRd', opRd);
    await p.setDouble('$_root.plate', plate);
    await p.setDouble('$_root.blur', blur);
    await p.setDouble('$_root.hue', hue);
    await p.setDouble('$_root.sat', sat);
    await p.setDouble('$_root.bri', bri);
    await p.setBool('$_root.applyApp', applyApp);
    await p.setBool('$_root.applyRd', applyRd);

    await p.setBool('$_root.authed', authed);
    await p.setBool('$_root.loggedIn', loggedIn);
    await p.setString('$_root.userName', userName);
    await p.setString('$_root.bookmarks', bookmarks.join(','));
    await p.setString('$_root.customFonts', encodeFonts(customFonts));
  }

  void _update(VoidCallback fn) {
    fn();
    notifyListeners();
    persist();
  }

  // ==========================================================
  // 派生样式
  // ==========================================================
  Palette get palette {
    if (paperKey == 'auto') {
      final Brightness b =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return paletteByKey(b == Brightness.dark ? 'night' : 'clear');
    }
    return paletteByKey(paperKey);
  }

  /// 夜间自动把强调色提亮，避免深红糊在深底上
  Color get accent {
    final Color base = parseHex(accentHex);
    return palette.dark ? mixColor(base, Colors.white, 0.34) : base;
  }

  Color get accentSoft =>
      accent.withOpacity(palette.dark ? 0.18 : 0.10);

  /// 正文实际使用的字体 family（null = 系统默认）
  String? get bodyFontFamily {
    if (fontKey.startsWith('custom:')) {
      return fontKey.substring('custom:'.length);
    }
    switch (fontKey) {
      case 'serif':
        return 'serif';
      case 'round':
        return 'sans-serif';
      default:
        return null;
    }
  }

  /// 全局应用的字体（"仅正文"模式下标题不跟着换）
  String? get globalFontFamily => fontScope == 'all' ? bodyFontFamily : null;

  String get fontLabel {
    if (fontKey.startsWith('custom:')) {
      final String fam = fontKey.substring('custom:'.length);
      for (final CustomFont f in customFonts) {
        if (f.family == fam) return f.name;
      }
      return '自定义字体';
    }
    switch (fontKey) {
      case 'serif':
        return '衬线 · 宋体';
      case 'round':
        return '圆润 · 黑体';
      default:
        return '系统默认字体';
    }
  }

  ThemeData toThemeData() {
    final Palette p = palette;
    final TextTheme base = ThemeData.light().textTheme;
    return ThemeData(
      useMaterial3: true,
      fontFamily: globalFontFamily,
      brightness: p.dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: p.paper,
      canvasColor: p.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: p.dark ? Brightness.dark : Brightness.light,
      ).copyWith(
        surface: p.paper,
        primary: accent,
        onPrimary: Colors.white,
      ),
      textTheme: base.apply(bodyColor: p.ink, displayColor: p.ink),
      dividerColor: p.line,
      splashFactory: InkSparkle.splashFactory,
    );
  }

  // ==========================================================
  // 字体导入 / 移除
  // ==========================================================
  Future<void> _reloadFonts() async {
    for (final CustomFont f in customFonts) {
      final File file = File(f.path);
      if (!await file.exists()) continue;
      try {
        final Uint8List bytes = await file.readAsBytes();
        final FontLoader loader = FontLoader(f.family)
          ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
        await loader.load();
      } catch (_) {
        // 字体损坏就跳过，不影响启动
      }
    }
  }

  /// 从文件管理器挑一个字体文件并立即生效
  Future<String> importFont() async {
    final FilePickerResult? res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['ttf', 'otf', 'woff', 'woff2'],
      withData: true,
    );
    if (res == null || res.files.isEmpty) return '';
    final PlatformFile pf = res.files.first;
    if (pf.bytes == null) return '';

    final Directory dir = await getApplicationSupportDirectory();
    final Directory fontDir = Directory('${dir.path}/fonts');
    if (!await fontDir.exists()) await fontDir.create(recursive: true);

    final String stamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String ext = (pf.extension ?? 'ttf').toLowerCase();
    final String path = '${fontDir.path}/f$stamp.$ext';
    await File(path).writeAsBytes(pf.bytes!, flush: true);

    final String family = 'cf_$stamp';
    try {
      final FontLoader loader = FontLoader(family)
        ..addFont(
            Future<ByteData>.value(ByteData.sublistView(pf.bytes!)));
      await loader.load();
    } catch (_) {
      await File(path).delete();
      return '这个字体文件加载失败，换一个 .ttf 试试';
    }

    final String name = pf.name.replaceAll(RegExp(r'\.[^.]+$'), '');
    _update(() {
      customFonts = <CustomFont>[
        ...customFonts,
        CustomFont(
          family: family,
          name: name,
          path: path,
          bytes: pf.bytes!.length,
        ),
      ];
      fontKey = 'custom:$family';
    });
    return '';
  }

  Future<void> removeFont(CustomFont f) async {
    if (fontKey == 'custom:${f.family}') fontKey = 'sans';
    customFonts = customFonts.where((CustomFont e) => e.family != f.family).toList();
    notifyListeners();
    await persist();
    try {
      final File file = File(f.path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  // ==========================================================
  // 背景图
  // ==========================================================
  Future<String> pickBackground() async {
    final FilePickerResult? res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res == null || res.files.isEmpty) return '';
    final PlatformFile pf = res.files.first;
    if (pf.bytes == null) return '';

    final Directory dir = await getApplicationSupportDirectory();
    final Directory bgDir = Directory('${dir.path}/bg');
    if (!await bgDir.exists()) await bgDir.create(recursive: true);

    final String stamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String ext = (pf.extension ?? 'jpg').toLowerCase();
    final String path = '${bgDir.path}/bg_$stamp.$ext';
    await File(path).writeAsBytes(pf.bytes!, flush: true);

    final String? old = bgPath;
    _update(() {
      bgPath = path;
      bgEnabled = true;
      applyApp = true;
      applyRd = true;
    });
    if (old != null && old.isNotEmpty) {
      try {
        final File f = File(old);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    return '';
  }

  // ==========================================================
  // 各种 setter（都带持久化）
  // ==========================================================
  void setPaper(String key) => _update(() => paperKey = key);
  void setAccent(String hex) => _update(() => accentHex = hex);
  void setFontScope(String v) => _update(() => fontScope = v);
  void setFontKey(String v) => _update(() => fontKey = v);
  void setReaderMode(String v) => _update(() => readerMode = v);
  void setFlipMode(String v) => _update(() => flipMode = v);
  void setFontSize(double v) => _update(() => fontSize = v.clamp(14, 26));
  void setLineHeight(double v) => _update(() => lineHeight = v);
  void setTranslate(bool v) => _update(() => translate = v);
  void setTranslateDisplay(String v) => _update(() => translateDisplay = v);

  void setBgEnabled(bool v) => _update(() => bgEnabled = v);

  /// 使用打包在 App 里的示例背景图
  void setBgAsset(String path) => _update(() {
        bgPath = 'asset:$path';
        bgEnabled = true;
        applyApp = true;
        applyRd = true;
      });

  void clearBg() => _update(() => bgEnabled = false);
  void setApplyApp(bool v) => _update(() => applyApp = v);
  void setApplyRd(bool v) => _update(() => applyRd = v);
  void setOpApp(double v) => _update(() => opApp = v);
  void setOpRd(double v) => _update(() => opRd = v);
  void setPlate(double v) => _update(() => plate = v);
  void setBlur(double v) => _update(() => blur = v);
  void setHue(double v) => _update(() => hue = v);
  void setSat(double v) => _update(() => sat = v);
  void setBri(double v) => _update(() => bri = v);

  void toggleBookmark(int id) {
    _update(() {
      if (bookmarks.contains(id)) {
        bookmarks = <int>{...bookmarks}..remove(id);
      } else {
        bookmarks = <int>{...bookmarks, id};
      }
    });
  }

  void login(String name, {bool guest = false}) => _update(() {
        authed = true;
        loggedIn = !guest;
        if (guest) {
          userName = '访客';
        } else if (name.trim().isNotEmpty) {
          userName = name.trim();
        }
      });

  void logout() => _update(() {
        authed = false;
        loggedIn = false;
      });

  void resetAppearance() => _update(() {
        paperKey = 'clear';
        accentHex = '#9c1f26';
        fontKey = 'serif';
        fontScope = 'all';
        fontSize = 18;
        lineHeight = 1.85;
        readerMode = 'scroll';
        flipMode = 'tap';
        bgEnabled = false;
        opApp = 0.30;
        opRd = 0.30;
        plate = 0.55;
        blur = 2;
        hue = 0;
        sat = 1;
        bri = 1;
        applyApp = true;
        applyRd = true;
      });
}
