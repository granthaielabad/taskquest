import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _progressAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.stop(); // ✅ Stop animation before navigating
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, animation, _) => const OnboardingScreen(),
            transitionsBuilder: (_, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ── Layer 1: Grid background ───────────────────────────
          const Positioned.fill(
            child: RepaintBoundary( // ✅ Isolates grid from repaints
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
          ),

          // ── Layer 2: Corner accent — top left ──────────────────
          const Positioned(
            top: 80,
            left: 36,
            child: SizedBox(
              width: 28,
              height: 28,
              child: CustomPaint(
                painter: _CornerPainter(topLeft: true),
              ),
            ),
          ),

          // ── Layer 3: Corner accent — bottom right ──────────────
          const Positioned(
            bottom: 130,
            right: 36,
            child: SizedBox(
              width: 28,
              height: 28,
              child: CustomPaint(
                painter: _CornerPainter(topLeft: false),
              ),
            ),
          ),

          // ── Layer 4: Centre logo + tagline ─────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/logo.svg',
                      width: 52,
                      height: 52,
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'TaskQuest',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                        letterSpacing: -0.64,
                        color: AppTheme.black,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'CONQUER YOUR DAY',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    letterSpacing: 2.2,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),

          // ── Layer 5: Animated progress loader ──────────────────
          //    RepaintBoundary isolates animation repaints to this
          //    widget only — rest of screen is untouched each frame
          Positioned(
            bottom: 90,
            left: 40,
            right: 40,
            child: RepaintBoundary(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnim,
                      builder: (context, _) => FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnim.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.black,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'LOADING YOUR QUESTS…',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontWeight: FontWeight.w400,
                      fontSize: 9,
                      letterSpacing: 1.62,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Layer 6: Version string ────────────────────────────
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              'v1.0.0 · TaskQuest',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontWeight: FontWeight.w400,
                fontSize: 9,
                letterSpacing: 1.26,
                color: AppTheme.border,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grid painter ───────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double scaleX = size.width / 390;
    final double scaleY = size.height / 844;

    final double v1 = 130 * scaleX;
    final double v2 = 260 * scaleX;
    final double h1 = 280 * scaleY;
    final double h2 = 560 * scaleY;

    canvas.drawLine(Offset(v1, 0), Offset(v1, size.height), paint);
    canvas.drawLine(Offset(v2, 0), Offset(v2, size.height), paint);
    canvas.drawLine(Offset(0, h1), Offset(size.width, h1), paint);
    canvas.drawLine(Offset(0, h2), Offset(size.width, h2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Corner painter ─────────────────────────────────────────────────────
class _CornerPainter extends CustomPainter {
  final bool topLeft;
  const _CornerPainter({required this.topLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    if (topLeft) {
      canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
      canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
    } else {
      canvas.drawLine(
          Offset(0, size.height), Offset(size.width, size.height), paint);
      canvas.drawLine(
          Offset(size.width, 0), Offset(size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}