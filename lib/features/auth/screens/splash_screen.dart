import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/shared/widgets/main_scaffold.dart';
import 'package:taskquest/features/auth/screens/onboarding_screen.dart';
import 'package:taskquest/features/auth/screens/login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    
    if (authState.value == null) {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => hasSeenOnboarding
                ? const LoginScreen()
                : const OnboardingScreen(),
          ),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScaffold()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Grid Background ─────────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(
                color: colorScheme.onSurface.withValues(alpha: 0.03),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Original Logo (No border, maximized size)
                Hero(
                  tag: 'logo',
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 120, 
                    height: 120,
                    colorFilter: ColorFilter.mode(
                      colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'TaskQuest',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                    letterSpacing: -1.0,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 160,
                  child: LinearProgressIndicator(
                    backgroundColor: colorScheme.outline.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(colorScheme.onSurface),
                    minHeight: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const spacing = 40.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
