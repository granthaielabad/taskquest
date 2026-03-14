// profile_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: const SafeArea(child: Center(child: Text('Profile — Coming Soon',
        style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700,
            fontSize: 18, color: AppTheme.black)))),
  );
}