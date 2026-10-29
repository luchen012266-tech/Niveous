import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../pager.dart';
import '../palettes.dart';
import '../widgets/paper_scaffold.dart';
import 'settings_screen.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({
    super.key,
    required this.work,
    required this.chapterIndex,
  });

  final Work work;
  final int chapterIndex;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late int _chapter = widget.chapterIndex;
  int _page = 0;
  bool _chrome = true;
  double _progress = 0;
  final ScrollController _sc = ScrollController();

  List<List<ReaderBlock>> _pages = <List<ReaderBlock>>[];
  String _sig = '';

  Chapter get _cur => widget.work.chapters[_chapter];

  @override
  void initState() {
    super.initState();
    _sc.addListener(() {
      if (!_sc.hasClients) return;
      final double max = _sc.position.maxScrollExtent;
      final double now = max <= 0 ? 0 : _sc.offset / max;
      if ((now - _progress).abs() > 0.005) {
        setState(() => _progress = now.clamp(0, 1));
      }
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  // ---------------- 正文拆块 ----------------
  TextStyle _styleFor(String kind, AppState s) {
    final Palette p = s.palette;
    final String? fam = s.bodyFontFamily;
    switch (kind) {
      case 'head':
        return TextStyle(
          fontFamily: fam,
          fontSize: s.fontSize + 6,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: p.ink,
        );
      case 'meta':
        return TextStyle(fontSize: 11.5, height: 1.6, color: p.muted);
      case 'zh':
        return TextStyle(
          fontFamily: fam,
          fontSize: s.fontSize - 2,
          height: 1.9,
          color: p.ink.withOpacity(0.94),
        );
      default:
        return TextStyle(
          fontFamily: fam,
          fontSize: s.fontSize,
          height: s.lineHeight,
          color: p.ink,
        );
    }
  }

  List<ReaderBlock> _blocks(AppState s) {
    final List<ReaderBlock> blocks = <ReaderBlock>[
      ReaderBlock(_cur.title, 'head', spaceAfter: 6),
      ReaderBlock(
        '${widget.work.displayTitle} — ${widget.work.author}',
        'meta',
        spaceAfter: 22,
      ),
    ];

    for (final Para para in _cur.paragraphs) {
      if (!s.translate) {
        blocks.add(ReaderBlock(para.en, 'en', spaceAfter: 18));
      } else if (s.translateDisplay == 'dual') {
        blocks.add(ReaderBlock(para.en, 'en', spaceAfter: 8));
        blocks.add(ReaderBlock(para.zh, 'zh', spaceAfter: 22));
      } else {
        blocks.add(ReaderBlock(para.zh, 'zh', spaceAfter: 18));
      }
    }
    return blocks;
  }

  // ---------------- 章节 / 翻页 ----------------
  void _goChapter(int delta) {
    final int n = _chapter + delta;
    if (n < 0) {
      _toast('已经是第一章');
      return;
    }
    if (n >= widget.work.chapters.length) {
      _toast('已经是最后一章');
      return;
    }
    setState(() {
      _chapter = n;
      _page = 0;
      _sig = '';
      _progress = 0;
    });
    if (_sc.hasClients) _sc.jumpTo(0);
  }

  void _turn(int delta) {
    if (delta < 0 && _page == 0) {
      _goChapter(-1);
      return;
    }
    if (delta > 0 && _page >= _pages.length - 1) {
      _goChapter(1);
      return;
    }
    final int next = (_page + delta).clamp(0, _pages.length - 1);
    setState(() => _page = next);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }

  // ---------------- 界面 ----------------
  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    final bool paged = s.readerMode == 'paged';

    return Scaffold(
      body: PaperScaffold(
        opacityOverride: s.opRd,
        useAppBackground: false,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext c, BoxConstraints cons) {
              // 关键：分页必须在构建子组件之前算好，
              // 否则底部进度条会读到上一帧的空列表（表现为永远显示 1/1）。
              if (paged) _repaginate(s, cons, showChrome: _chrome);

              return Column(
                children: <Widget>[
                  if (_chrome)
                    SizedBox(height: _kTopBarH, child: _topBar(context, s, p)),
                  Expanded(
                    child: paged ? _pagedBody(context, s, p) : _scrollBody(context, s, p),
                  ),
                  if (_chrome)
                    SizedBox(
                        height: _kBottomBarH,
                        child: _bottomBar(context, s, p, paged)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static const double _kTopBarH = 58;
  static const double _kBottomBarH = 36;
  static const double _kPadH = 20;
  static const double _kPadV = 18;

  void _repaginate(AppState s, BoxConstraints cons, {required bool showChrome}) {
    final double chromeH = showChrome ? (_kTopBarH + _kBottomBarH) : 0;
    // 扣掉正文衬底的外边距（左右 10、上下 6/4）与内边距
    final double w = cons.maxWidth - 20 - _kPadH * 2;
    final double h = cons.maxHeight - chromeH - 10 - _kPadV * 2;
    final String sig = '${_chapter}|${s.fontSize}|${s.lineHeight}|'
        '${s.bodyFontFamily}|${s.translate}|${s.translateDisplay}|'
        '${s.paperKey}|${w.round()}|${h.round()}';
    if (sig == _sig) return;
    final double ratio =
        _pages.isEmpty ? 0 : _page / _pages.length.clamp(1, 9999);
    _pages = Paginator.paginate(
      blocks: _blocks(s),
      width: w,
      height: h,
      styleOf: (String kind) => _styleFor(kind, s),
    );
    _sig = sig;
    _page = (ratio * _pages.length).floor().clamp(0, _pages.length - 1);
  }

  Widget _topBar(BuildContext context, AppState s, Palette p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line.withOpacity(0.6))),
      ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.ink.withOpacity(0.06),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.chevron_left, size: 20, color: p.ink),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.work.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'serif',
                    color: p.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '第 ${_chapter + 1}/${widget.work.chapters.length} 章 · '
                  '${s.readerMode == 'paged' ? '左右翻页' : '上下滑动'}',
                  style: TextStyle(fontSize: 10.5, color: p.muted),
                ),
              ],
            ),
          ),
          _RoundBtn(
            active: s.translate,
            icon: Icons.translate,
            onTap: () => s.setTranslate(!s.translate),
          ),
          const SizedBox(width: 8),
          _RoundBtn(
            icon: Icons.format_size,
            onTap: () => _quickSettings(context),
          ),
          const SizedBox(width: 8),
          _RoundBtn(
            icon: Icons.menu,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plate(AppState s, Palette p, Widget child) {
    // 正文衬底：让文字在照片背景上依然清楚
    final bool hasBg = s.bgEnabled && s.applyRd && s.bgPath != null;
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 4),
      decoration: BoxDecoration(
        color: hasBg ? p.paper.withOpacity(s.plate) : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _scrollBody(BuildContext context, AppState s, Palette p) {
    final List<ReaderBlock> blocks = _blocks(s);
    return _plate(
      s,
      p,
      ListView.builder(
        controller: _sc,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 60),
        itemCount: blocks.length,
        itemBuilder: (BuildContext c, int i) {
          final ReaderBlock b = blocks[i];
          return Padding(
            padding: EdgeInsets.only(bottom: b.spaceAfter),
            child: Text(b.text, style: _styleFor(b.kind, s)),
          );
        },
      ),
    );
  }

  Widget _pagedBody(BuildContext context, AppState s, Palette p) {
    final List<ReaderBlock> page =
        _pages.isEmpty ? <ReaderBlock>[] : _pages[_page];

    return _plate(
      s,
      p,
      Stack(
        children: <Widget>[
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: _kPadH, vertical: _kPadV),
              child: ClipRect(
                // 用不可滚动的 ListView：内容略超一两个像素时不会触发溢出断言
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    for (final ReaderBlock b in page)
                      Padding(
                        padding: EdgeInsets.only(bottom: b.spaceAfter),
                        child: Text(b.text, style: _styleFor(b.kind, s)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (BuildContext c2, BoxConstraints c3) {
                void handleTap(double x, double wf) {
                  if (x < wf * 0.32) {
                    _turn(-1);
                  } else if (x > wf * 0.68) {
                    _turn(1);
                  } else {
                    setState(() => _chrome = !_chrome);
                  }
                }

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapUp: s.flipMode == 'tap'
                      ? (TapUpDetails d) => handleTap(
                          d.localPosition.dx, c3.maxWidth)
                      : null,
                  onTap: s.flipMode == 'tap'
                      ? null
                      : () => setState(() => _chrome = !_chrome),
                  onHorizontalDragEnd: s.flipMode != 'swipe'
                      ? null
                      : (DragEndDetails d) {
                          final double v = d.primaryVelocity ?? 0;
                          if (v < -80) {
                            _turn(1);
                          } else if (v > 80) {
                            _turn(-1);
                          }
                        },
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context, AppState s, Palette p, bool paged) {
    final double shown = paged
        ? (_pages.isEmpty ? 0 : (_page + 1) / _pages.length)
        : _progress;
    final String label = paged
        ? '${_pages.isEmpty ? 1 : _page + 1} / ${_pages.isEmpty ? 1 : _pages.length}'
        : '${(shown * 100).round()}%';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 52,
            child: Text(label,
                style: TextStyle(fontSize: 11, color: p.muted)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: shown,
                minHeight: 3,
                backgroundColor: p.ink.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(s.accent),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _goChapter(1),
            child: Text('下一章 ›',
                style: TextStyle(fontSize: 11.5, color: p.muted)),
          ),
        ],
      ),
    );
  }

  // ---------------- 快速设置（阅读页里直接调） ----------------
  void _quickSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext c) => const _QuickSettingsSheet(),
    );
  }
}

class _QuickSettingsSheet extends StatelessWidget {
  const _QuickSettingsSheet();

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.paper,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 10, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: p.line,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _Seg(
                  options: const <String, String>{
                    'scroll': '上下滑动',
                    'paged': '左右翻页'
                  },
                  value: s.readerMode,
                  onPick: s.setReaderMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LabeledSlider(
            label: '字号',
            value: s.fontSize,
            min: 14,
            max: 26,
            divisions: 12,
            display: '${s.fontSize.round()} px',
            onChanged: s.setFontSize,
          ),
          LabeledSlider(
            label: '阅读页背景透明度',
            value: s.opRd * 100,
            min: 0,
            max: 100,
            display: '${(s.opRd * 100).round()}%',
            onChanged: (double v) => s.setOpRd(v / 100),
          ),
          LabeledSlider(
            label: '正文衬底浓度',
            value: s.plate * 100,
            min: 0,
            max: 100,
            display: '${(s.plate * 100).round()}%',
            onChanged: (double v) => s.setPlate(v / 100),
          ),
          LabeledSlider(
            label: '色相',
            value: s.hue,
            min: 0,
            max: 360,
            display: '${s.hue.round()}°',
            onChanged: s.setHue,
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: p.ink2,
                side: BorderSide(color: p.line),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text('更多设置 · 字体 / 换图 / 模糊'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? s.accent : p.ink.withOpacity(0.06),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 17, color: active ? Colors.white : p.ink),
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.options,
    required this.value,
    required this.onPick,
  });

  final Map<String, String> options;
  final String value;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: s.accentSoft,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: options.entries.map((MapEntry<String, String> e) {
          final bool on = e.key == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPick(e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? p.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: on ? p.ink : p.ink2,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
