import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../palettes.dart';

class WorkCard extends StatelessWidget {
  const WorkCard({
    super.key,
    required this.work,
    required this.onOpen,
    required this.onBookmark,
    required this.bookmarked,
  });

  final Work work;
  final VoidCallback onOpen;
  final VoidCallback onBookmark;
  final bool bookmarked;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    final Color ratingColor = Color(kRatingColors[work.rating] ?? 0xFF999999);

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(p.dark ? 0.30 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(width: 4, color: ratingColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          _Badge(
                            text: work.rating,
                            color: ratingColor,
                            textColor: Colors.white,
                            bold: true,
                          ),
                          const SizedBox(width: 6),
                          if (work.complete)
                            _Badge(
                              text: '完结',
                              color: const Color(0xFFE8F3E8),
                              textColor: const Color(0xFF2E7D32),
                            ),
                          if (work.zhReady) ...<Widget>[
                            const SizedBox(width: 6),
                            _Badge(
                              text: '已有译文',
                              color: p.dark
                                  ? const Color(0xFF123027)
                                  : const Color(0xFFE3F4EE),
                              textColor: p.dark
                                  ? const Color(0xFF5EC9A3)
                                  : const Color(0xFF0B6E4F),
                            ),
                          ],
                          const Spacer(),
                          Text('${work.year}',
                              style:
                                  TextStyle(fontSize: 10.5, color: p.muted)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        work.displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17.5,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: p.ink,
                        ),
                      ),
                      if (work.hasZhTitle) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          work.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            color: p.muted,
                            fontFamily: 'serif',
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(children: <InlineSpan>[
                          TextSpan(
                            text: 'by ',
                            style: TextStyle(color: p.muted, fontSize: 12),
                          ),
                          TextSpan(
                            text: work.author,
                            style: TextStyle(
                              color: p.ink2,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        work.fandom,
                        style: TextStyle(
                          fontSize: 12,
                          color: s.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: work.tags
                            .take(3)
                            .map((String t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: s.accentSoft,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    t,
                                    style: TextStyle(
                                        fontSize: 11, color: p.ink2),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        work.summaryZh,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13, height: 1.65, color: p.ink2),
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: p.line),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Icon(Icons.favorite,
                              size: 12, color: p.muted.withOpacity(0.8)),
                          const SizedBox(width: 4),
                          Text(work.kudos,
                              style:
                                  TextStyle(fontSize: 11.5, color: p.muted)),
                          const SizedBox(width: 12),
                          Icon(Icons.visibility_outlined,
                              size: 13, color: p.muted.withOpacity(0.8)),
                          const SizedBox(width: 4),
                          Text(work.hits,
                              style:
                                  TextStyle(fontSize: 11.5, color: p.muted)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${work.words} 词 · ${work.chapterCount} 章',
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(fontSize: 11.5, color: p.muted),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: onBookmark,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: bookmarked ? s.accent : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: bookmarked ? s.accent : p.line,
                                ),
                              ),
                              child: Icon(
                                Icons.bookmark_border,
                                size: 15,
                                color: bookmarked ? Colors.white : p.muted,
                              ),
                            ),
                          ),
                        ],
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

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.color,
    required this.textColor,
    this.bold = false,
  });

  final String text;
  final Color color;
  final Color textColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          height: 1.2,
          color: textColor,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
