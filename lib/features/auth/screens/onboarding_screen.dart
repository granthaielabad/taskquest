import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskquest/features/auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    _goToLogin();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => const LoginScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Page content
            PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              physics: const ClampingScrollPhysics(),
              pageSnapping: true,
              children: const [_Slide1(), _Slide2(), _Slide3()],
            ),

            // Skip button
            if (_currentPage < 2)
              Positioned(
                top: 12,
                right: 24,
                child: TextButton(
                  onPressed: _goToLogin,
                  child: Text(
                    'SKIP',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomControls(
                currentPage: _currentPage,
                onNext: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom controls
class _BottomControls extends StatelessWidget {
  final int currentPage;
  final VoidCallback onNext;

  const _BottomControls({required this.currentPage, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(3, (i) {
              final isActive = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 6),
                width: isActive ? 24 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? colorScheme.onSurface : colorScheme.outline,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // CTA button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.onSurface,
                foregroundColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentPage < 2 ? 'Next' : 'Get Started',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: colorScheme.surface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: colorScheme.surface,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '${currentPage + 1} of 3',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 11,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Slide 1
class _Slide1 extends StatefulWidget {
  const _Slide1();

  @override
  State<_Slide1> createState() => _Slide1State();
}

class _Slide1State extends State<_Slide1> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: _GameCard(
                  icon: Icons.style_rounded,
                  title: 'Flashcards',
                  subtitle: 'Manual or AI-generated\nfrom your files',
                  tag: 'AI ✦',
                  isDark: true,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _GameCard(
                  icon: Icons.code_rounded,
                  title: 'Code Blocks',
                  subtitle: 'Drag & drop missing\ncode into place',
                  tag: 'INTERACTIVE',
                  isDark: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: const [
              Expanded(
                child: _GameCard(
                  icon: Icons.quiz_rounded,
                  title: 'Which Lang?',
                  subtitle: 'Identify programming\nlanguages from clues',
                  tag: 'QUIZ',
                  isDark: false,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _GameCard(
                  icon: Icons.account_tree_rounded,
                  title: 'SDLC Sequence',
                  subtitle: 'Arrange software dev\nphases in order',
                  tag: 'PUZZLE',
                  isDark: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          const _AlgorithmCard(),
          const SizedBox(height: 28),

          Text(
            '01 — WHAT IS TASKQUEST?',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              letterSpacing: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Learn CS\nthrough play.',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 36,
              letterSpacing: -1.0,
              color: colorScheme.onSurface,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Five interactive game modes designed to sharpen your programming and computational thinking skills.',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// Slide 2
class _Slide2 extends StatefulWidget {
  const _Slide2();

  @override
  State<_Slide2> createState() => _Slide2State();
}

class _Slide2State extends State<_Slide2> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TIME REMAINING',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 9,
                            letterSpacing: 1.2,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '00:35',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        letterSpacing: 1.0,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: 0.70,
                    minHeight: 5,
                    backgroundColor: colorScheme.outline,
                    valueColor: AlwaysStoppedAnimation(colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.onSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FILL IN THE MISSING CODE',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    letterSpacing: 1.2,
                    color: colorScheme.surface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 12,
                      height: 1.8,
                    ),
                    children: [
                      const TextSpan(
                        text: 'function ',
                        style: TextStyle(color: Color(0xFF7BA3F5)),
                      ),
                      TextSpan(
                        text: 'greet',
                        style: TextStyle(color: colorScheme.surface),
                      ),
                      TextSpan(
                        text: '(name) {\n  ',
                        style: TextStyle(color: colorScheme.surface.withValues(alpha: 0.8)),
                      ),
                      const TextSpan(
                        text: 'return ',
                        style: TextStyle(color: Color(0xFF7BA3F5)),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          width: 72,
                          height: 20,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      TextSpan(
                        text: ' + name;\n}',
                        style: TextStyle(color: colorScheme.surface.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: const [
                    _CodeChip(label: '"Hello, "'),
                    _CodeChip(label: 'console.log'),
                    _CodeChip(label: 'null'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Text(
            'INSTANT FEEDBACK',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 9,
              letterSpacing: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(color: colorScheme.onSurface, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Correct!',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"Hello, " concatenates with the name parameter correctly.',
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 9,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.outline),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Incorrect',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'null would cause a type error when concatenated.',
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 9,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Difficulty adapts as you level up — tasks get harder the better you get.',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 28),

          Text(
            '02 — HOW IT WORKS',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              letterSpacing: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Think fast,\nlearn faster.',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 36,
              letterSpacing: -1.0,
              color: colorScheme.onSurface,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Timed challenges keep you focused. Instant feedback tells you exactly what you got right — and why you got it wrong.',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// Slide 3
class _Slide3 extends StatefulWidget {
  const _Slide3();

  @override
  State<_Slide3> createState() => _Slide3State();
}

class _Slide3State extends State<_Slide3> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.onSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SESSION SCORE',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 9,
                        letterSpacing: 1.4,
                        color: colorScheme.surface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '1,840',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            fontSize: 36,
                            color: colorScheme.surface,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'pts',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 13,
                            color: colorScheme.surface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '12  correct',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 11,
                        color: colorScheme.surface,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3  missed',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 11,
                        color: colorScheme.surface.withValues(alpha: 0.5),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level 4',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SKILL BREAKDOWN',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    letterSpacing: 1.4,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                const _SkillBar(label: 'Programming Logic', value: 0.82),
                const SizedBox(height: 12),
                const _SkillBar(label: 'Syntax Knowledge', value: 0.67),
                const SizedBox(height: 12),
                const _SkillBar(label: 'SDLC Concepts', value: 0.55),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACHIEVEMENTS UNLOCKED',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    letterSpacing: 1.4,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _AchievementBadge(
                      icon: Icons.star_rounded,
                      label: 'First Quest',
                      unlocked: true,
                    ),
                    _AchievementBadge(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Code Cracker',
                      unlocked: true,
                    ),
                    _AchievementBadge(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Flashmaster',
                      unlocked: true,
                    ),
                    _AchievementBadge(
                      icon: Icons.lock_outline_rounded,
                      label: 'Algorithm Pro',
                      unlocked: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          Text(
            '03 — TRACK & EARN',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              letterSpacing: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'See your\ngrowth,\nearn your\nbadges.',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 36,
              letterSpacing: -1.0,
              color: colorScheme.onSurface,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Every session shows your skill breakdown. Complete challenges to unlock achievement badges and level up your CS profile.',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final bool isDark;

  const _GameCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bg = isDark ? colorScheme.onSurface : colorScheme.surface;
    final border = isDark ? colorScheme.onSurface : colorScheme.outline;
    final titleColor = isDark ? colorScheme.surface : colorScheme.onSurface;
    final subColor = isDark ? colorScheme.surface.withValues(alpha: 0.45) : colorScheme.onSurfaceVariant;
    final tagBg = isDark
        ? colorScheme.surface.withValues(alpha: 0.12)
        : theme.scaffoldBackgroundColor;
    final tagColor = isDark ? colorScheme.surface.withValues(alpha: 0.55) : colorScheme.onSurfaceVariant;
    final iconBg = isDark
        ? colorScheme.surface.withValues(alpha: 0.12)
        : theme.scaffoldBackgroundColor;
    final iconColor = isDark ? colorScheme.surface : colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              border: Border.all(
                color: isDark ? Colors.transparent : colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: -0.13,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 9,
              color: subColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: tagBg,
              border: Border.all(
                color: isDark ? Colors.transparent : colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 8,
                letterSpacing: 0.8,
                color: tagColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlgorithmCard extends StatelessWidget {
  const _AlgorithmCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.functions_rounded,
              color: colorScheme.onSurface,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solve an Algorithm',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Work through pseudocode problem-solving challenges step by step',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'LOGIC',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 8,
                letterSpacing: 0.8,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeChip extends StatelessWidget {
  final String label;
  const _CodeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.1),
        border: Border.all(color: colorScheme.surface.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 10,
          color: colorScheme.surface.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  final String label;
  final double value;
  const _SkillBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 11,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 5,
            backgroundColor: colorScheme.outline,
            valueColor: AlwaysStoppedAnimation(colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool unlocked;

  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: unlocked ? colorScheme.onSurface : colorScheme.surface,
            border: Border.all(
              color: unlocked
                  ? colorScheme.onSurface
                  : colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: unlocked ? colorScheme.surface : colorScheme.outline,
            size: 22,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 9,
              color: unlocked
                  ? colorScheme.onSurface
                  : colorScheme.outline,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
