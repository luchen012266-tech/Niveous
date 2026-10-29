import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppState state = await AppState.load();
  runApp(AppScope(state: state, child: const ReaderApp()));
}

class ReaderApp extends StatelessWidget {
  const ReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    return MaterialApp(
      title: 'Archive Reader',
      debugShowCheckedModeBanner: false,
      theme: s.toThemeData(),
      home: s.authed ? const HomeShell() : const LoginScreen(),
    );
  }
}
