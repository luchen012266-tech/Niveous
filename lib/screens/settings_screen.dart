import 'package:flutter/material.dart';

import '../app_state.dart';
import '../palettes.dart';
import '../widgets/paper_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;

    return Scaffold(
      body: PaperScaffold(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              _Header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: <Widget>[
                    _Sec(
                      title: '正文字号',
                      trailing: '${s.fontSize.round()} px',
                      child: Row(
                        children: <Widget>[
                          _SquareBtn(
                            label: 'A−',
                            onTap: () => s.setFontSize(s.fontSize - 1),
                          ),
                          Expanded(
                            child: Slider(
                              value: s.fontSize,
                              min: 14,
                              max: 26,
                              divisions: 12,
                              activeColor: s.accent,
                              inactiveColor: p.line,
                              onChanged: s.setFontSize,
                            ),
                          ),
                          _SquareBtn(
                            label: 'A+',
                            onTap: () => s.setFontSize(s.fontSize + 1),
                          ),
                        ],
                      ),
                    ),
                    _FontSection(),
                    _Sec(
                      title: '字体应用范围',
                      hint: '不确定就选「全局」。选「仅正文」时，标题和列表仍用内置字体。',
                      child: _Seg(
                        options: const <String, String>{
                          'all': '全局（含标题/列表）',
                          'body': '仅正文',
                        },
                        value: s.fontScope,
                        onPick: s.setFontScope,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 22),
                        decoration: BoxDecoration(
                          color: p.card.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: p.line),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '浮光落在纸页上。他放下书，轻声说：\n“不着急，慢慢读。”',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: s.bodyFontFamily,
                            fontSize: 17,
                            height: 1.85,
                            color: p.ink,
                          ),
                        ),
                      ),
                    ),
                    _Sec(
                      title: '背景颜色',
                      hint: '默认「清透白」是纯白底，没有任何黄色。',
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          for (final Palette item in kPalettes)
                            _ColorDot(
                              color: item.swatchColor,
                              selected: s.paperKey == item.key,
                              onTap: () => s.setPaper(item.key),
                            ),
                          _FollowChip(
                            selected: s.paperKey == 'auto',
                            onTap: () => s.setPaper('auto'),
                          ),
                        ],
                      ),
                    ),
                    _Sec(
                      title: '主题色',
                      hint: '只影响按钮、标签、进度条这些强调色，不影响纸面。',
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          for (final AccentPreset a in kAccents)
                            _ColorDot(
                              color: parseHex(a.hex),
                              selected: s.accentHex == a.hex,
                              onTap: () => s.setAccent(a.hex),
                            ),
                        ],
                      ),
                    ),
                    _Sec(
                      title: '自定义背景图片',
                      hint: '选一张图当纸面底纹，用透明度滑块控制浓淡；首页和阅读页可以分别调。',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 96,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                _PickThumb(
                                  asset: 'assets/bg/rain.jpg',
                                  label: '雨夜',
                                  selected:
                                      s.bgPath == 'asset:assets/bg/rain.jpg',
                                  onTap: () => s.setBgAsset('assets/bg/rain.jpg'),
                                ),
                                _PickThumb(
                                  asset: 'assets/bg/dusk.jpg',
                                  label: '暮色',
                                  selected:
                                      s.bgPath == 'asset:assets/bg/dusk.jpg',
                                  onTap: () => s.setBgAsset('assets/bg/dusk.jpg'),
                                ),
                                _PickThumb(
                                  asset: 'assets/bg/mist.jpg',
                                  label: '雾青',
                                  selected:
                                      s.bgPath == 'asset:assets/bg/mist.jpg',
                                  onTap: () => s.setBgAsset('assets/bg/mist.jpg'),
                                ),
                                _NoBgThumb(
                                  selected: !s.bgEnabled,
                                  onTap: s.clearBg,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _WideButton(
                            icon: Icons.upload_file,
                            label: '从相册选择图片',
                            onTap: () async {
                              final String err = await s.pickBackground();
                              if (err.isNotEmpty && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(err)),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 6),
                          _CheckRow(
                            label: '应用到首页',
                            value: s.applyApp,
                            onChanged: s.setApplyApp,
                          ),
                          _CheckRow(
                            label: '应用到阅读页',
                            value: s.applyRd,
                            onChanged: s.setApplyRd,
                          ),
                          LabeledSlider(
                            label: '首页背景透明度',
                            value: s.opApp * 100,
                            min: 0,
                            max: 100,
                            display: '${(s.opApp * 100).round()}%',
                            onChanged: (double v) => s.setOpApp(v / 100),
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
                            label: '阅读页正文衬底',
                            value: s.plate * 100,
                            min: 0,
                            max: 100,
                            display: '${(s.plate * 100).round()}%',
                            onChanged: (double v) => s.setPlate(v / 100),
                          ),
                          LabeledSlider(
                            label: '背景模糊',
                            value: s.blur,
                            min: 0,
                            max: 14,
                            display: '${s.blur.round()} px',
                            onChanged: s.setBlur,
                          ),
                          LabeledSlider(
                            label: '色相',
                            value: s.hue,
                            min: 0,
                            max: 360,
                            display: '${s.hue.round()}°',
                            onChanged: s.setHue,
                          ),
                          LabeledSlider(
                            label: '浓淡',
                            value: s.sat * 100,
                            min: 20,
                            max: 180,
                            display: '${(s.sat * 100).round()}%',
                            onChanged: (double v) => s.setSat(v / 100),
                          ),
                          LabeledSlider(
                            label: '明暗',
                            value: s.bri * 100,
                            min: 40,
                            max: 150,
                            display: '${(s.bri * 100).round()}%',
                            onChanged: (double v) => s.setBri(v / 100),
                          ),
                        ],
                      ),
                    ),
                    _Sec(
                      title: '翻页方式',
                      hint: '翻页无动画，直接切换内容。',
                      child: _Seg(
                        options: const <String, String>{
                          'tap': '点击左右',
                          'swipe': '左右滑动',
                        },
                        value: s.flipMode,
                        onPick: s.setFlipMode,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                decoration: BoxDecoration(
                  color: p.paper.withOpacity(0.98),
                  border: Border(top: BorderSide(color: p.line)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _OutlineButton(
                          label: '恢复默认',
                          onTap: s.resetAppearance,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FillButton(
                          label: '保存',
                          onTap: () async {
                            await s.persist();
                            if (context.mounted) Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// 字体区（内置 + 自定义导入）
// =====================================================================
class _FontSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;

    return _Sec(
      title: '正文字体',
      hint: '可以导入手机里的 .ttf / .otf 字体，导入后全站立刻套用。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.line),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(s.fontLabel,
                      style: TextStyle(fontSize: 14, color: p.ink)),
                ),
                Icon(Icons.expand_more, size: 18, color: p.muted),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _WideButton(
            icon: Icons.upload_file,
            label: '从文件添加字体（.ttf / .otf / .woff2）',
            onTap: () async {
              final String err = await s.importFont();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(err.isEmpty ? '字体已导入：${s.fontLabel}' : err),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _FontRow(
            title: '系统默认字体',
            family: null,
            selected: s.fontKey == 'sans',
            onUse: () => s.setFontKey('sans'),
          ),
          _FontRow(
            title: '衬线 · 宋体',
            family: 'serif',
            selected: s.fontKey == 'serif',
            onUse: () => s.setFontKey('serif'),
          ),
          _FontRow(
            title: '圆润 · 黑体',
            family: 'sans-serif',
            selected: s.fontKey == 'round',
            onUse: () => s.setFontKey('round'),
          ),
          for (final CustomFont f in s.customFonts)
            _FontRow(
              title: f.name,
              subtitle: '${(f.bytes / 1024 / 1024).toStringAsFixed(2)} MB',
              family: f.family,
              selected: s.fontKey == 'custom:${f.family}',
              onUse: () => s.setFontKey('custom:${f.family}'),
              onDelete: () => s.removeFont(f),
            ),
          if (s.customFonts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '还没有自定义字体。导入后可以在上面这个列表里切换。',
                style: TextStyle(fontSize: 11.5, height: 1.7, color: p.muted),
              ),
            ),
        ],
      ),
    );
  }
}

class _FontRow extends StatelessWidget {
  const _FontRow({
    required this.title,
    required this.family,
    required this.selected,
    required this.onUse,
    this.subtitle,
    this.onDelete,
  });

  final String title;
  final String? family;
  final bool selected;
  final VoidCallback onUse;
  final String? subtitle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(13, 11, 11, 11),
      decoration: BoxDecoration(
        color: p.card.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? s.accent : p.line),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Aa 浮光落在纸页上',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: family, fontSize: 18, color: p.ink),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle == null ? title : '$title · $subtitle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5, color: p.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onUse,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? s.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: selected ? s.accent : p.line),
              ),
              child: Text(
                selected ? '使用中' : '使用',
                style: TextStyle(
                  fontSize: 11.5,
                  color: selected ? Colors.white : p.ink2,
                ),
              ),
            ),
          ),
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.close, size: 15, color: p.muted),
              ),
            ),
        ],
      ),
    );
  }
}

// =====================================================================
// 通用小部件
// =====================================================================
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Palette p = AppScope.of(context).palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('阅读设置',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'serif',
                      color: p.ink,
                    )),
                const SizedBox(height: 6),
                Text(
                  '字号与字体在所有界面共用；背景图可以分别设定首页与阅读页的浓淡。',
                  style:
                      TextStyle(fontSize: 11.5, height: 1.65, color: p.muted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: p.line),
              ),
              child: Text('✕', style: TextStyle(color: p.ink2, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sec extends StatelessWidget {
  const _Sec({
    required this.title,
    required this.child,
    this.hint,
    this.trailing,
  });

  final String title;
  final Widget child;
  final String? hint;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final Palette p = AppScope.of(context).palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    )),
              ),
              if (trailing != null)
                Text(trailing!,
                    style: TextStyle(fontSize: 12, color: p.muted)),
            ],
          ),
          if (hint != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(hint!,
                style:
                    TextStyle(fontSize: 11.5, height: 1.7, color: p.muted)),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SquareBtn extends StatelessWidget {
  const _SquareBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Palette p = AppScope.of(context).palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: p.line),
        ),
        child: Text(label, style: TextStyle(fontSize: 17, color: p.ink)),
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
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? p.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  e.value,
                  textAlign: TextAlign.center,
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

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? s.accent : p.line,
            width: selected ? 2.5 : 1,
          ),
        ),
      ),
    );
  }
}

class _FollowChip extends StatelessWidget {
  const _FollowChip({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? s.accent : p.line),
        ),
        child: Text('跟随主题',
            style: TextStyle(fontSize: 12.5, color: p.ink2)),
      ),
    );
  }
}

class _PickThumb extends StatelessWidget {
  const _PickThumb({
    required this.asset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String asset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 74,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? s.accent : Colors.transparent,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(asset, fit: BoxFit.cover),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 12, bottom: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.black.withOpacity(0.55),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoBgThumb extends StatelessWidget {
  const _NoBgThumb({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 74,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? s.accent : p.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text('无背景',
            style: TextStyle(fontSize: 11, color: p.muted)),
      ),
    );
  }
}

class _WideButton extends StatelessWidget {
  const _WideButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Palette p = AppScope.of(context).palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.line, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 15, color: p.ink2),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(fontSize: 13, color: p.ink2)),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? s.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: value ? s.accent : p.line),
              ),
              child: value
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 9),
            Text(label,
                style: TextStyle(fontSize: 12.5, color: p.ink2)),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Palette p = AppScope.of(context).palette;
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink2,
          side: BorderSide(color: p.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _FillButton extends StatelessWidget {
  const _FillButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: s.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
