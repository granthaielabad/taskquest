import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardSlide> _slides = const [
    _OnboardSlide(
      emoji: '🗺️',
      title: 'Learn CS\nthrough play.',
      subtitle:
      'Five interactive game modes designed to sharpen your programming and computational thinking skills.',
    ),
    _OnboardSlide(
      emoji: '⚔️',
      title: 'Think fast,\nlearn faster.',
      subtitle:
      'Time challenges keep you focused. Instant feedback tells you exactly what you got right — and why you got it wrong.',
    ),
    _OnboardSlide(
      emoji: '🏆',
      title: 'See your\ngrowth,\nearn your\nbadges. ',
      subtitle:
      'Every session shows your skills breakdown. Complete challenges to unlock achievement badges and level up your CS profile.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
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
      body: SafeArea(
        child: Column(
          children: [
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlideContent(slide: _slides[i]),
              ),
            ),

            // Dots indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.black : AppTheme.dimmed,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),

            // CTA buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage < _slides.length - 1
                              ? 'Next'
                              : 'Get Started',
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_currentPage < _slides.length - 1)
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 11,
                          color: AppTheme.muted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Slide data model ─────────────────────────────────────────────────
class _OnboardSlide {
  final String emoji;
  final String title;
  final String subtitle;
  const _OnboardSlide({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

// ── Slide content widget ─────────────────────────────────────────────
class _SlideContent extends StatelessWidget {
  final _OnboardSlide slide;
  const _SlideContent({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji
          Text(slide.emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 32),

          // Title
          Text(
            slide.title,
            style: const TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 30,
              letterSpacing: -0.9,
              color: AppTheme.black,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),

          // Subtitle
          Text(
            slide.subtitle,
            style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 13,
              color: AppTheme.muted,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}