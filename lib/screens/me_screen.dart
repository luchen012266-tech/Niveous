import 'package:flutter/material.dart';

import '../app_state.dart';
import '../palettes.dart';
import '../widgets/paper_scaffold.dart';
import 'settings_screen.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;

    return Scaffold(
      body: PaperScaffold(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
                child: Text('我的',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'serif',
                      color: p.ink,
                    )),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.line),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            s.accent,
                            Color.lerp(s.accent, Colors.white, 0.35)!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        s.userName.isEmpty
                            ? '访'
                            : s.userName.characters.first.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'serif',
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(s.userName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'serif',
                                color: p.ink,
                              )),
                          const SizedBox(height: 3),
                          Text(
                            s.loggedIn ? '已登录 AO3 · 会话有效' : '访客模式 · 仅可浏览公开作品',
                            style: TextStyle(
                                fontSize: 11.5, color: p.muted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: s.accentSoft,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        s.translate ? '翻译开' : '翻译关',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: s.accent),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    _Stat(label: '书签', value: '${s.bookmarks.length}'),
                    const SizedBox(width: 10),
                    _Stat(label: '阅读历史', value: '0'),
                    const SizedBox(width: 10),
                    _Stat(label: '离线缓存', value: '0'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ListBox(
                rows: <Widget>[
                  _Row(
                    icon: Icons.format_size,
                    label: '阅读与背景设置',
                    trailing: s.readerMode == 'paged' ? '左右翻页 ›' : '上下滑动 ›',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen()),
                    ),
                  ),
                  _Row(
                    icon: Icons.translate,
                    label: '翻译',
                    trailing: s.translate ? '已开启 ›' : '已关闭 ›',
                    onTap: () => s.setTranslate(!s.translate),
                  ),
                  _Row(
                    icon: Icons.filter_alt_outlined,
                    label: '内容过滤',
                    trailing: 'Explicit 显示 ›',
                    onTap: () {},
                  ),
                  _Row(
                    icon: Icons.wifi_outlined,
                    label: '网络与代理',
                    trailing: '直连 ›',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ListBox(
                rows: <Widget>[
                  _Row(
                    icon: Icons.info_outline,
                    label: '关于',
                    trailing: 'v0.1.0 原型 ›',
                    onTap: () {},
                  ),
                  _Row(
                    icon: Icons.logout,
                    label: '退出登录',
                    trailing: '',
                    danger: true,
                    onTap: s.logout,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  '本应用不托管任何作品内容，所有文本来自 AO3 并缓存在本机。\n'
                  '非官方客户端，请遵守 AO3 使用条款并控制请求频率。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, height: 1.8, color: p.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final Palette p = AppScope.of(context).palette;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: p.line),
        ),
        child: Column(
          children: <Widget>[
            Text(value,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'serif',
                  color: p.ink,
                )),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10.5, color: p.muted)),
          ],
        ),
      ),
    );
  }
}

class _ListBox extends StatelessWidget {
  const _ListBox({required this.rows});
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final Palette p = AppScope.of(context).palette;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows.length; i++)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: i == rows.length - 1 ? Colors.transparent : p.line,
                  ),
                ),
              ),
              child: rows[i],
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String trailing;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: s.accentSoft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 15, color: s.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: danger ? s.accent : p.ink,
                  )),
            ),
            Text(trailing,
                style: TextStyle(fontSize: 11.5, color: p.muted)),
          ],
        ),
      ),
    );
  }
}
