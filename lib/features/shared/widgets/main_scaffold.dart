import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:taskquest/features/home/screens/home_screen.dart';
import 'package:taskquest/features/games/screens/games_screen.dart';
import 'package:taskquest/features/explore/screens/explore_screen.dart';
import 'package:taskquest/features/games/screens/flashcard_scan_screen.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/profile/profile_screen.dart';
import 'package:taskquest/features/shared/widgets/bottom_nav_bar.dart';
import 'package:taskquest/core/providers/tutorial_provider.dart';
import 'package:taskquest/core/providers/theme_provider.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  final Set<int> _activatedTabs = {0};
  TutorialCoachMark? tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performStartupHandshake();
    });
  }

  void _showWalkthrough() {
    _createTutorial();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        tutorialCoachMark?.show(context: context);
      }
    });
  }

  void _createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black,
      textSkip: "SKIP GUIDE",
      alignSkip: Alignment.topRight,
      paddingFocus: 5,
      opacityShadow: 0.9,
      // ── Handle scrolling when moving to next target ───────────
      onClickTarget: (target) => _handleScroll(target),
      onClickOverlay: (target) => _handleScroll(target),
      onFinish: () => ref.read(walkthroughProvider.notifier).completeWalkthrough(),
      onSkip: () {
        ref.read(walkthroughProvider.notifier).completeWalkthrough();
        return true;
      },
    );
  }

  void _handleScroll(TargetFocus target) {
    // Determine which target is next and scroll to it
    final allTargets = _createTargets();
    final currentIndex = allTargets.indexWhere((t) => t.identify == target.identify);
    if (currentIndex != -1 && currentIndex < allTargets.length - 1) {
      final nextTarget = allTargets[currentIndex + 1];
      final nextContext = nextTarget.keyTarget?.currentContext;
      if (nextContext != null) {
        Scrollable.ensureVisible(
          nextContext,
          duration: const Duration(milliseconds: 600),
          alignment: 0.5,
        );
      }
    }
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "streak",
        keyTarget: WalkthroughKeys.streakKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                title: "Your Progress",
                body: "Track your current streak and level progress here. Keep learning to maintain your streak!",
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "challenges",
        keyTarget: WalkthroughKeys.challengesKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                title: "Daily Quests",
                body: "Complete these tasks daily to earn XP and level up your scholar profile.",
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "games",
        keyTarget: WalkthroughKeys.gamesKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                title: "Game Modes",
                body: "Jump into interactive minigames to practice syntax, logic, and algorithms in a fun way.",
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "navScan",
        keyTarget: WalkthroughKeys.navScanKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                title: "AI Scanner",
                body: "The heart of TaskQuest! Scan your physical notes to turn them into digital flashcards instantly.",
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "navExplore",
        keyTarget: WalkthroughKeys.navExploreKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                title: "Explore & Compete",
                body: "Discover new content and check the Global Ranking to see where you stand among other scholars.",
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }

  Widget _buildTutorialContent({required String title, required String body}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 16,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'DM Mono',
              color: Colors.white70,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "TAP TO CONTINUE",
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 8,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _performStartupHandshake() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await ref
          .read(userServiceProvider)
          .checkAndCreateProfile(
            user.uid,
            user.email ?? '',
            user.displayName ?? '',
          );
    }
  }

  void _onTabTap(int index) {
    ref.read(navigationIndexProvider.notifier).setIndex(index);
    setState(() {
      _activatedTabs.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);
    ref.listen<bool>(walkthroughProvider, (previous, next) {
      if (next == false) {
        _showWalkthrough();
      }
    });

    final List<Widget> screens = [
      const HomeScreen(),
      const GamesScreen(),
      const FlashcardScanScreen(),
      const ExploreScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: List.generate(screens.length, (i) {
          if (!_activatedTabs.contains(i)) return const SizedBox.shrink();
          return Offstage(
            offstage: currentIndex != i,
            child: TickerMode(enabled: currentIndex == i, child: screens[i]),
          );
        }),
      ),
      bottomNavigationBar: TQBottomNav(
        currentIndex: currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}
