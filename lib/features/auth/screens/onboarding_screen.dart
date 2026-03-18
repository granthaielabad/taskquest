import 'package:flutter/material.dart';
import 'package:taskquest/core/theme/app_theme.dart';
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
        duration: const Duration(milliseconds: 350), // ✅ slightly snappier
        curve: Curves.easeOutCubic,                  // ✅ smoother curve
      );
    } else {
      _goToLogin();
    }
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Page content ──────────────────────────────────────
            PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              // ✅ ClampingScrollPhysics = snappier, no bounce lag
              physics: const ClampingScrollPhysics(),
              pageSnapping: true,
              children: const [
                _Slide1(),
                _Slide2(),
                _Slide3(),
              ],
            ),

            // ── Skip button ───────────────────────────────────────
            if (_currentPage < 2)
              Positioned(
                top: 12,
                right: 24,
                child: TextButton(
                  onPressed: _goToLogin,
                  child: const Text(
                    'SKIP',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: AppTheme.muted,
                    ),
                  ),
                ),
              ),

            // ── Bottom controls ───────────────────────────────────
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

// ── Bottom controls ────────────────────────────────────────────────────
class _BottomControls extends StatelessWidget {
  final int currentPage;
  final VoidCallback onNext;

  const _BottomControls({
    required this.currentPage,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(3, (i) {
              final isActive = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250), // ✅ tighter
                margin: const EdgeInsets.only(right: 6),
                width: isActive ? 24 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.black : AppTheme.dimmed,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // CTA button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.black,
                foregroundColor: Colors.white,
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
          ),
          const SizedBox(height: 12),

          Text(
            '${currentPage + 1} of 3',
            style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 11,
              color: AppTheme.dimmed,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// SLIDE 1
// ✅ StatefulWidget + AutomaticKeepAliveClientMixin
//    → slide stays in memory after swiping away, no rebuild on return
// ══════════════════════════════════════════════════════════════════════
class _Slide1 extends StatefulWidget {
  const _Slide1();

  @override
  State<_Slide1> createState() => _Slide1State();
}

class _Slide1State extends State<_Slide1>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by mixin
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1
          const Row(
            children: [
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

          // Row 2
          const Row(
            children: [
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

          // Row 3 — full width
          const _AlgorithmCard(),
          const SizedBox(height: 28),

          const Text(
            '01 — WHAT IS TASKQUEST?',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              letterSpacing: 1.4,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Learn CS\nthrough play.',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 36,
              letterSpacing: -1.0,
              color: AppTheme.black,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Five interactive game modes designed to sharpen your programming and computational thinking skills.',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 12,
              color: AppTheme.muted,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// SLIDE 2
// ══════════════════════════════════════════════════════════════════════
class _Slide2 extends StatefulWidget {
  const _Slide2();

  @override
  State<_Slide2> createState() => _Slide2State();
}

class _Slide2State extends State<_Slide2>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timer bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 12, color: AppTheme.muted),
                        SizedBox(width: 6),
                        Text(
                          'TIME REMAINING',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 9,
                            letterSpacing: 1.2,
                            color: AppTheme.muted,
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
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: const LinearProgressIndicator(
                    value: 0.70,
                    minHeight: 5,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation(AppTheme.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Code block card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.black,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FILL IN THE MISSING CODE',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    letterSpacing: 1.2,
                    color: Color(0xFF777777),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontFamily: 'DM Mono', fontSize: 12, height: 1.8),
                    children: [
                      const TextSpan(
                          text: 'function ',
                          style: TextStyle(color: Color(0xFF7BA3F5))),
                      const TextSpan(
                          text: 'greet',
                          style: TextStyle(color: Colors.white)),
                      const TextSpan(
                          text: '(name) {\n  ',
                          style: TextStyle(color: Color(0xFFCCCCCC))),
                      const TextSpan(
                          text: 'return ',
                          style: TextStyle(color: Color(0xFF7BA3F5))),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          width: 72,
                          height: 20,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const TextSpan(
                          text: ' + name;\n}',
                          style: TextStyle(color: Color(0xFFCCCCCC))),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 8,
                  children: [
                    _CodeChip(label: '"Hello, "'),
                    _CodeChip(label: 'console.log'),
                    _CodeChip(label: 'null'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            'INSTANT FEEDBACK',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 9,
              letterSpacing: 1.4,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 8),

          // Feedback cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    border: Border.all(color: AppTheme.black, width: 1.5),
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
                            decoration: const BoxDecoration(
                              color: AppTheme.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Correct!',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppTheme.black,
                              )),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '"Hello, " concatenates with the name parameter correctly.',
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 9,
                          color: AppTheme.muted,
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
                    color: AppTheme.white,
                    border: Border.all(color: AppTheme.border),
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
                              border: Border.all(color: AppTheme.dimmed),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Incorrect',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: AppTheme.muted,
                              )),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'null would cause a type error when concatenated.',
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 9,
                          color: AppTheme.muted,
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

          // Difficulty hint
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Difficulty adapts as you level up — tasks get harder the better you get.',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 10,
                color: AppTheme.muted,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            '02 — HOW IT WORKS',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              letterSpacing: 1.4,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Think fast,\nlearn faster.',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 36,
              letterSpacing: -1.0,
              color: AppTheme.black,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Timed challenges keep you focused. Instant feedback tells you exactly what you got right — and why you got it wrong.',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 12,
              color: AppTheme.muted,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// SLIDE 3
// ══════════════════════════════════════════════════════════════════════
class _Slide3 extends StatefulWidget {
  const _Slide3();

  @override
  State<_Slide3> createState() => _Slide3State();
}

class _Slide3State extends State<_Slide3>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SESSION SCORE',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 9,
                        letterSpacing: 1.4,
                        color: Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 6),
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
                            color: Colors.white,
                            letterSpacing: -1.0,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'pts',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('12  correct',
                        style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 11,
                            color: Colors.white,
                            letterSpacing: 0.3)),
                    SizedBox(height: 4),
                    Text('3  missed',
                        style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 11,
                            color: Color(0xFF666666),
                            letterSpacing: 0.3)),
                    SizedBox(height: 4),
                    Text('Level 4',
                        style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Skill breakdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SKILL BREAKDOWN',
                    style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 9,
                        letterSpacing: 1.4,
                        color: AppTheme.muted)),
                SizedBox(height: 14),
                _SkillBar(label: 'Programming Logic', value: 0.82),
                SizedBox(height: 12),
                _SkillBar(label: 'Syntax Knowledge', value: 0.67),
                SizedBox(height: 12),
                _SkillBar(label: 'SDLC Concepts', value: 0.55),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Achievements
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ACHIEVEMENTS UNLOCKED',
                    style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 9,
                        letterSpacing: 1.4,
                        color: AppTheme.muted)),
                const SizedBox(height: 14),
                // ✅ No const on list — _AchievementBadge uses runtime bool
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AchievementBadge(
                        icon: Icons.star_rounded,
                        label: 'First Quest',
                        unlocked: true),
                    _AchievementBadge(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Code Cracker',
                        unlocked: true),
                    _AchievementBadge(
                        icon: Icons.auto_awesome_rounded,
                        label: 'Flashmaster',
                        unlocked: true),
                    _AchievementBadge(
                        icon: Icons.lock_outline_rounded,
                        label: 'Algorithm Pro',
                        unlocked: false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          const Text('03 — TRACK & EARN',
              style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  letterSpacing: 1.4,
                  color: AppTheme.muted)),
          const SizedBox(height: 12),
          const Text(
            'See your\ngrowth,\nearn your\nbadges.',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 36,
              letterSpacing: -1.0,
              color: AppTheme.black,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Every session shows your skill breakdown. Complete challenges to unlock achievement badges and level up your CS profile.',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 12,
              color: AppTheme.muted,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Game mode card ─────────────────────────────────────────────────────
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
    final bg = isDark ? AppTheme.black : AppTheme.white;
    final border = isDark ? AppTheme.black : AppTheme.border;
    final titleColor = isDark ? Colors.white : AppTheme.black;
    final subColor =
        isDark ? Colors.white.withValues(alpha: 0.45) : AppTheme.muted;
    final tagBg =
        isDark ? Colors.white.withValues(alpha: 0.12) : AppTheme.background;
    final tagColor =
        isDark ? Colors.white.withValues(alpha: 0.55) : AppTheme.muted;
    final iconBg =
        isDark ? Colors.white.withValues(alpha: 0.12) : AppTheme.background;
    final iconColor = isDark ? Colors.white : AppTheme.black;

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
                  color: isDark ? Colors.transparent : AppTheme.border),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: -0.13,
                  color: titleColor)),
          const SizedBox(height: 5),
          Text(subtitle,
              style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 9,
                  color: subColor,
                  height: 1.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: tagBg,
              border: Border.all(
                  color: isDark ? Colors.transparent : AppTheme.border),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(tag,
                style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 8,
                    letterSpacing: 0.8,
                    color: tagColor)),
          ),
        ],
      ),
    );
  }
}

// ── Algorithm card ─────────────────────────────────────────────────────
class _AlgorithmCard extends StatelessWidget {
  const _AlgorithmCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.functions_rounded,
                color: AppTheme.black, size: 16),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Solve an Algorithm',
                    style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.black)),
                SizedBox(height: 3),
                Text(
                  'Work through pseudocode problem-solving challenges step by step',
                  style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 9,
                      color: AppTheme.muted,
                      height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text('LOGIC',
                style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 8,
                    letterSpacing: 0.8,
                    color: AppTheme.muted)),
          ),
        ],
      ),
    );
  }
}

// ── Code chip ──────────────────────────────────────────────────────────
class _CodeChip extends StatelessWidget {
  final String label;
  const _CodeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        border: Border.all(color: const Color(0xFF444444)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              color: Color(0xFFCCCCCC))),
    );
  }
}

// ── Skill bar ──────────────────────────────────────────────────────────
class _SkillBar extends StatelessWidget {
  final String label;
  final double value;
  const _SkillBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 11,
                    color: AppTheme.black)),
            Text('${(value * 100).round()}%',
                style: const TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 11,
                    color: AppTheme.muted)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 5,
            backgroundColor: AppTheme.border,
            valueColor: const AlwaysStoppedAnimation(AppTheme.black),
          ),
        ),
      ],
    );
  }
}

// ── Achievement badge ──────────────────────────────────────────────────
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
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: unlocked
                ? const Color(0xFF111111)
                : const Color(0xFFF7F6F2),
            border: Border.all(
              color: unlocked
                  ? const Color(0xFF111111)
                  : const Color(0xFFE2E1DC),
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: unlocked ? Colors.white : const Color(0xFFCCCAC4),
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
              // ✅ Color literals instead of AppTheme — avoids const issues
              color: unlocked
                  ? const Color(0xFF111111)
                  : const Color(0xFFCCCAC4),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}