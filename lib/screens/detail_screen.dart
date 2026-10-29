import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../palettes.dart';
import '../widgets/paper_scaffold.dart';
import 'reader_screen.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.work});

  final Work work;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    final bool bm = s.bookmarks.contains(work.id);

    return Scaffold(
      body: PaperScaffold(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _Hero(work: work),
                  _Section(
                    title: '摘要',
                    child: Text(
                      work.summaryZh,
                      style: TextStyle(
                          fontSize: 14, height: 1.8, color: p.ink2),
                    ),
                  ),
                  _Section(
                    title: '标签',
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: <Widget>[
                        ...work.tagsZh.map((String t) => _Tag(text: t)),
                        ...work.relationship.split('/').map(
                              (String r) => _Tag(text: r, accent: true),
                            ),
                        ...work.warnings.map(
                          (String w) => _Tag(text: '⚠ $w', outline: true),
                        ),
                      ],
                    ),
                  ),
                  _Section(
                    title: '章节目录',
                    last: true,
                    child: Column(
                      children: <Widget>[
                        for (int i = 0; i < work.chapters.length; i++)
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ReaderScreen(
                                  work: work,
                                  chapterIndex: i,
                                ),
                              ),
                            ),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: i == work.chapters.length - 1
                                        ? Colors.transparent
                                        : p.line,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 26,
                                    height: 26,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: s.accentSoft,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: s.accent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          work.chapters[i].title,
                                          style: TextStyle(
                                              fontSize: 14, color: p.ink),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${work.chapters[i].paragraphs.length} 段',
                                          style: TextStyle(
                                              fontSize: 11, color: p.muted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      size: 18, color: p.muted),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: p.paper.withOpacity(0.96),
                border: Border(top: BorderSide(color: p.line)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ReaderScreen(
                                  work: work, chapterIndex: 0),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: s.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('开始阅读',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          s.setTranslate(true);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ReaderScreen(
                                  work: work, chapterIndex: 0),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: p.ink2,
                          side: BorderSide(color: p.line),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('译文'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => s.toggleBookmark(work.id),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: bm ? s.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: bm ? s.accent : p.line),
                        ),
                        child: Icon(Icons.bookmark_border,
                            size: 19,
                            color: bm ? Colors.white : p.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.work});
  final Work work;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.lerp(s.accent, Colors.black, 0.55)!,
            Color.lerp(s.accent, Colors.black, 0.18)!,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.22)),
                      ),
                      child: const Icon(Icons.chevron_left,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                work.displayTitle,
                style: const TextStyle(
                  fontSize: 23,
                  height: 1.3,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'by ${work.author}'
                '${work.hasZhTitle ? ' · ${work.title}' : ''}',
                style: TextStyle(
                    fontSize: 13, color: Colors.white.withOpacity(0.85)),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <String>[
                  '评级 ${work.rating}',
                  work.complete ? '完结' : '连载中',
                  '${work.words} 词',
                  '${work.chapterCount} 章',
                  '♥ ${work.kudos}',
                  '阅读 ${work.hits}',
                ]
                    .map((String t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(t,
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.white.withOpacity(0.92))),
                        ))
                    .toList(),
              ),
              if (p.dark) const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.last = false,
  });

  final String title;
  final Widget child;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final Palette p = AppScope.of(context).palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: last ? Colors.transparent : p.line),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11.5,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: p.muted,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, this.accent = false, this.outline = false});

  final String text;
  final bool accent;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: outline
            ? Colors.transparent
            : (accent ? s.accentSoft : s.accentSoft),
        borderRadius: BorderRadius.circular(8),
        border: outline ? Border.all(color: p.line) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: accent ? s.accent : p.ink2,
        ),
      ),
    );
  }
}
