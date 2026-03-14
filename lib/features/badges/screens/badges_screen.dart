// badges_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: const SafeArea(child: Center(child: Text('Badges — Coming Soon',
        style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700,
            fontSize: 18, color: AppTheme.black)))),
  );
}