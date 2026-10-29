import 'package:flutter/material.dart';

import '../app_state.dart';
import '../palettes.dart';
import '../widgets/paper_scaffold.dart';
import 'settings_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _user =
      TextEditingController(text: 'wandered_off');
  final TextEditingController _pass = TextEditingController(text: 'demo1234');

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;

    return Scaffold(
      body: PaperScaffold(
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              // 右上角：深浅色 + 设置
              Positioned(
                top: 12,
                right: 16,
                child: Row(
                  children: <Widget>[
                    _TopIconButton(
                      icon: Icons.brightness_6_outlined,
                      onTap: () => s.setPaper(p.dark ? 'clear' : 'night'),
                    ),
                    const SizedBox(width: 8),
                    _TopIconButton(
                      icon: Icons.settings_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: s.accent,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: s.accent.withOpacity(0.28),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'A',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Archive Reader',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'serif',
                                  color: p.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '一个更舒服的 AO3 阅读器',
                                style: TextStyle(
                                    fontSize: 12, color: p.muted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 34),
                      _FieldLabel('AO3 用户名 / 邮箱', color: p.muted),
                      _PTextField(controller: _user, hint: 'your_ao3_name'),
                      const SizedBox(height: 14),
                      _FieldLabel('密码', color: p.muted),
                      _PTextField(
                        controller: _pass,
                        hint: '••••••••',
                        obscure: true,
                      ),
                      const SizedBox(height: 20),
                      _PrimaryButton(
                        label: '登录',
                        onTap: () => s.login(_user.text),
                      ),
                      const SizedBox(height: 10),
                      _GhostButton(
                        label: '以访客身份浏览',
                        onTap: () => s.login('', guest: true),
                      ),
                      const SizedBox(height: 22),
                      Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: '原型说明：',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: p.ink2,
                              ),
                            ),
                            TextSpan(
                              text: '真实版本走 AO3 官方登录表单，凭据只保存在手机本地'
                                  '（EncryptedSharedPreferences），用来获取你自己的书签、'
                                  '阅读历史和私密作品。',
                            ),
                          ],
                          style: TextStyle(
                              fontSize: 11.5, height: 1.7, color: p.muted),
                        ),
                        textAlign: TextAlign.center,
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

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: p.card.withOpacity(0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.line),
        ),
        child: Icon(icon, size: 18, color: p.ink2),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3, bottom: 6),
      child: Text(text, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}

class _PTextField extends StatelessWidget {
  const _PTextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(fontSize: 15, color: p.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: p.muted, fontSize: 14),
        filled: true,
        fillColor: p.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: s.accent, width: 1.6),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: s.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label,
            style:
                const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final Palette p = s.palette;
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink2,
          side: BorderSide(color: p.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
