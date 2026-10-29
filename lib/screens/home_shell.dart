import 'package:flutter/material.dart';

import '../app_state.dart';
import '../palettes.dart';
import 'discover_screen.dart';
import 'me_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const <Widget>[
          DiscoverScreen(),
          DiscoverScreen(libraryOnly: true),
          MeScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: p.paper.withOpacity(0.94),
          border: Border(top: BorderSide(color: p.line)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Row(
              children: <Widget>[
                _NavItem(
                  icon: Icons.search,
                  label: '发现',
                  on: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  icon: Icons.bookmark_border,
                  label: '书库',
                  on: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  label: '我的',
                  on: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.on,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    final Color c = on ? s.accent : p.muted;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 21, color: c),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: c,
                fontWeight: on ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
