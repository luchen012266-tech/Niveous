import 'dart:io';

import 'package:ao3_reader/app_state.dart';
import 'package:ao3_reader/main.dart';
import 'package:ao3_reader/screens/reader_screen.dart';
import 'package:ao3_reader/screens/settings_screen.dart';
import 'package:ao3_reader/demo_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> loadFont(String family, String path) async {
  final File f = File(path);
  final FontLoader l = FontLoader(family)
    ..addFont(Future<ByteData>.value(ByteData.sublistView(f.readAsBytesSync())));
  await l.load();
}

void main() {
  setUpAll(() async {
    // 测试环境没有中文字体，这里临时注册一份，仅用于截图预览
    await loadFont('Roboto', '../tooling/fonts/NotoSansCJK.ttf');
    await loadFont('serif', '../tooling/fonts/NotoSerifCJK.ttf');
    await loadFont('sans-serif', '../tooling/fonts/NotoSansCJK.ttf');
    await loadFont('MaterialIcons', '../tooling/fonts/MaterialIcons-Regular.otf');
  });

  testWidgets('capture screens', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final AppState state = AppState();
    await tester.pumpWidget(AppScope(state: state, child: const ReaderApp()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('preview/01_login.png'));

    await tester.tap(find.text('以访客身份浏览'));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('preview/02_home.png'));

    await tester.tap(find.byType(GestureDetector).at(0));
    await tester.pumpAndSettle();

    // 直接推详情 + 阅读器，避免 hit test 细节
    final NavigatorState nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    await tester.pumpWidget(AppScope(state: state, child: const ReaderApp()));
    await tester.pumpAndSettle();

    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp(
        theme: state.toThemeData(),
        debugShowCheckedModeBanner: false,
        home: const SettingsScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('preview/03_settings.png'));

    state.setTranslate(true);
    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp(
        theme: state.toThemeData(),
        debugShowCheckedModeBanner: false,
        home: ReaderScreen(work: kDemoWorks[0], chapterIndex: 0),
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('preview/04_reader_scroll.png'));

    state.setReaderMode('paged');
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('preview/05_reader_paged.png'));

    state.setPaper('night');
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('preview/06_reader_night.png'));
    nav.toString();
  });
}
