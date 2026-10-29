import 'package:ao3_reader/app_state.dart';
import 'package:ao3_reader/demo_data.dart';
import 'package:ao3_reader/main.dart';
import 'package:ao3_reader/pager.dart';
import 'package:ao3_reader/screens/reader_screen.dart';
import 'package:ao3_reader/widgets/work_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 取出阅读器底部的 "1 / N" 页码文本
String pageLabelText(WidgetTester tester) {
  String found = '';
  for (final Element e in find.byType(Text).evaluate()) {
    final String? d = (e.widget as Text).data;
    if (d != null && RegExp(r'^\d+ / \d+$').hasMatch(d)) found = d;
  }
  return found;
}

void main() {
  test('分页算法：内容不会被拆成半页', () {
    final List<ReaderBlock> blocks = <ReaderBlock>[
      for (int i = 0; i < 30; i++) ReaderBlock('段落 $i', 'en', spaceAfter: 16),
    ];
    final List<List<ReaderBlock>> pages = Paginator.paginate(
      blocks: blocks,
      width: 320,
      height: 600,
      styleOf: (String kind) =>
          const TextStyle(fontSize: 16, height: 1.8),
    );
    expect(pages.isNotEmpty, isTrue);
    final int total =
        pages.fold(0, (int a, List<ReaderBlock> b) => a + b.length);
    expect(total, blocks.length);
  });

  testWidgets('登录 → 首页 → 详情 → 阅读器 全流程可点', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final AppState state = AppState();

    await tester.pumpWidget(AppScope(state: state, child: const ReaderApp()));
    await tester.pumpAndSettle();

    expect(find.text('Archive Reader'), findsWidgets);

    await tester.tap(find.text('以访客身份浏览'));
    await tester.pumpAndSettle();

    expect(find.text('发现'), findsWidgets);
    expect(find.byType(WorkCard), findsWidgets);

    await tester.tap(find.byType(WorkCard).first);
    await tester.pumpAndSettle();

    expect(find.text('开始阅读'), findsOneWidget);

    await tester.tap(find.text('开始阅读'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.format_size), findsOneWidget);

    state.setReaderMode('paged');
    await tester.pumpAndSettle();
    expect(pageLabelText(tester), isNotEmpty);
  });

  testWidgets('翻页模式：长章节必须真的分成多页（防止退回 1/1）',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final AppState state = AppState();
    state.setReaderMode('paged');
    state.setTranslate(true); // 中英对照，内容更长

    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp(
        theme: state.toThemeData(),
        debugShowCheckedModeBanner: false,
        home: ReaderScreen(work: kDemoWorks[0], chapterIndex: 0),
      ),
    ));
    await tester.pumpAndSettle();

    final String label = pageLabelText(tester);
    expect(label, isNotEmpty, reason: '底部应显示页码');

    final int pages = int.parse(label.split('/').last.trim());
    expect(pages, greaterThan(1), reason: '长章节应分成多页，而不是永远 1 页');

    // 点右侧区域应该翻到第 2 页
    final Size size = tester.getSize(find.byType(Scaffold).last);
    await tester.tapAt(Offset(size.width * 0.9, size.height * 0.5));
    await tester.pumpAndSettle();
    expect(pageLabelText(tester).startsWith('2 /'), isTrue);
  });
}
