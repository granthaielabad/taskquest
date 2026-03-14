// explore_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: const SafeArea(child: Center(child: Text('Explore — Coming Soon',
        style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700,
            fontSize: 18, color: AppTheme.black)))),
  );
}