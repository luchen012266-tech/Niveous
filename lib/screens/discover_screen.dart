import 'package:flutter/material.dart';

import '../app_state.dart';
import '../demo_data.dart';
import '../models.dart';
import '../palettes.dart';
import '../widgets/paper_scaffold.dart';
import '../widgets/work_card.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key, this.libraryOnly = false});

  final bool libraryOnly;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _q = TextEditingController();
  String _status = 'all';
  String _sort = 'kudos';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  List<Work> _filtered(AppState s) {
    List<Work> list = widget.libraryOnly
        ? kDemoWorks.where((Work w) => s.bookmarks.contains(w.id)).toList()
        : List<Work>.of(kDemoWorks);

    final String q = _q.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((Work w) {
        final String blob = <String>[
          w.title,
          w.titleZh,
          w.author,
          w.fandom,
          ...w.tags,
          ...w.tagsZh,
        ].join(' ').toLowerCase();
        return blob.contains(q);
      }).toList();
    }

    switch (_status) {
      case 'done':
        list = list.where((Work w) => w.complete).toList();
      case 'wip':
        list = list.where((Work w) => !w.complete).toList();
      case 'zh':
        list = list.where((Work w) => w.zhReady).toList();
      case 'short':
        list = list
            .where((Work w) =>
                (int.tryParse(w.words.replaceAll(',', '')) ?? 0) < 10000)
            .toList();
    }

    int num(String v) => int.tryParse(v.replaceAll(',', '')) ?? 0;
    switch (_sort) {
      case 'kudos':
        list.sort((Work a, Work b) => num(b.kudos).compareTo(num(a.kudos)));
      case 'hits':
        list.sort((Work a, Work b) => num(b.hits).compareTo(num(a.hits)));
      case 'words':
        list.sort((Work a, Work b) => num(b.words).compareTo(num(a.words)));
      case 'new':
        list.sort((Work a, Work b) => b.year.compareTo(a.year));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    final List<Work> works = _filtered(s);

    return Scaffold(
      body: PaperScaffold(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 12, 6),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.libraryOnly ? '书库' : '发现',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'serif',
                              color: p.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.libraryOnly
                                ? '书库 · ${works.length} 篇收藏'
                                : '共 ${works.length} 篇作品 · 演示数据',
                            style:
                                TextStyle(fontSize: 11.5, color: p.muted),
                          ),
                        ],
                      ),
                    ),
                    _IconBtn(
                      icon: Icons.image_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => const SettingsScreen()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _IconBtn(
                      icon: Icons.brightness_6_outlined,
                      onTap: () => s.setPaper(p.dark ? 'clear' : 'night'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: p.line),
                  ),
                  child: TextField(
                    controller: _q,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(fontSize: 14.5, color: p.ink),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(Icons.search,
                          size: 18, color: p.muted.withOpacity(0.8)),
                      hintText: '搜索作品、作者、标签（如 slow burn）',
                      hintStyle: TextStyle(fontSize: 14, color: p.muted),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              _ChipRow(
                items: const <List<String>>[
                  <String>['all', '全部'],
                  <String>['done', '已完结'],
                  <String>['wip', '连载中'],
                  <String>['zh', '有中文译版'],
                  <String>['short', '短篇 < 1 万字'],
                ],
                active: _status,
                onPick: (String v) => setState(() => _status = v),
              ),
              _ChipRow(
                items: const <List<String>>[
                  <String>['kudos', '按 kudos'],
                  <String>['hits', '按浏览量'],
                  <String>['words', '按字数'],
                  <String>['new', '最近更新'],
                ],
                active: _sort,
                onPick: (String v) => setState(() => _sort = v),
                trailing: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                      color: p.card,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: p.line),
                    ),
                    child: Text('翻译 / 阅读设置',
                        style:
                            TextStyle(fontSize: 12.5, color: p.ink2)),
                  ),
                ),
              ),
              Expanded(
                child: works.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.menu_book_outlined,
                                size: 38,
                                color: p.muted.withOpacity(0.5)),
                            const SizedBox(height: 10),
                            Text(
                              widget.libraryOnly
                                  ? '书库还是空的\n在作品卡片上点书签图标收藏'
                                  : '没有匹配的作品',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  height: 1.9,
                                  color: p.muted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
                        itemCount: works.length,
                        itemBuilder: (BuildContext c, int i) {
                          final Work w = works[i];
                          return WorkCard(
                            work: w,
                            bookmarked: s.bookmarks.contains(w.id),
                            onBookmark: () => s.toggleBookmark(w.id),
                            onOpen: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => DetailScreen(work: w),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.items,
    required this.active,
    required this.onPick,
    this.trailing,
  });

  final List<List<String>> items;
  final String active;
  final ValueChanged<String> onPick;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
        children: <Widget>[
          ...items.map((List<String> it) {
            final bool on = active == it[0];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onPick(it[0]),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: on ? s.accent : p.card,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: on ? s.accent : p.line),
                  ),
                  child: Text(
                    it[1],
                    style: TextStyle(
                      fontSize: 12.5,
                      color: on ? Colors.white : p.ink2,
                      fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Palette p = AppScope.of(context).palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.line),
        ),
        child: Icon(icon, size: 18, color: p.ink2),
      ),
    );
  }
}
