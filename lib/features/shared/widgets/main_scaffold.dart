// Copyright (c) 2026 TaskQuest. All rights reserved.

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
      onFinish: () =>
          ref.read(walkthroughProvider.notifier).completeWalkthrough(),
      onSkip: () {
        ref.read(walkthroughProvider.notifier).completeWalkthrough();
        return true;
      },
    );
  }

  void _handleNext(String currentIdentify) {
    final allTargets = _createTargets();
    final currentIndex = allTargets.indexWhere(
      (t) => t.identify == currentIdentify,
    );

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
      Future.delayed(const Duration(milliseconds: 100), () {
        tutorialCoachMark?.next();
      });
    } else {
      tutorialCoachMark?.finish();
    }
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    void addTarget(
      String id,
      GlobalKey key,
      String title,
      String body, {
      ShapeLightFocus shape = ShapeLightFocus.RRect,
      ContentAlign align = ContentAlign.bottom,
    }) {
      targets.add(
        TargetFocus(
          identify: id,
          keyTarget: key,
          shape: shape,
          enableOverlayTab: false,
          enableTargetTab: false,
          contents: [
            TargetContent(
              align: align,
              builder: (context, controller) => _buildTutorialContent(
                title: title,
                body: body,
                onTap: () => _handleNext(id),
              ),
            ),
          ],
        ),
      );
    }

    addTarget(
      "greeting",
      WalkthroughKeys.greetingKey,
      "Welcome Scholar",
      "Your daily quest starts here. We'll keep you updated with personalized greetings.",
    );
    addTarget(
      "notification",
      WalkthroughKeys.notificationKey,
      "Stay Alert",
      "Check here for level-up alerts, quest reminders, and updates.",
      shape: ShapeLightFocus.Circle,
    );
    addTarget(
      "streak",
      WalkthroughKeys.streakKey,
      "Consistency is Key",
      "Your study streak and level progress. Keep the flame alive by completing daily tasks!",
    );
    addTarget(
      "leaderboard",
      WalkthroughKeys.leaderboardCardKey,
      "Compete Globally",
      "See the Global Ranking to compare your XP with other scholars.",
      align: ContentAlign.top,
    );
    addTarget(
      "badges",
      WalkthroughKeys.badgesCardKey,
      "Collect Achievements",
      "View your Hall of Achievements. master syntax and logic to earn unique badges.",
      align: ContentAlign.top,
    );
    addTarget(
      "challenges",
      WalkthroughKeys.challengesKey,
      "Daily Quests",
      "Your core missions for today. Complete them all to maximize XP.",
    );

    addTarget(
      "games",
      WalkthroughKeys.gamesKey,
      "Learning Minigames",
      "Engage in Syntax, Logic, and Algorithm challenges.",
    );
    addTarget(
      "activity",
      WalkthroughKeys.recentActivityKey,
      "Quest History",
      "A log of your recent accomplishments and rewards.",
      align: ContentAlign.top,
    );

    // Navbar
    addTarget(
      "navHome",
      WalkthroughKeys.navHomeKey,
      "Home Base",
      "The dashboard for your quests and rankings.",
      shape: ShapeLightFocus.Circle,
      align: ContentAlign.top,
    );
    addTarget(
      "navGames",
      WalkthroughKeys.navGamesKey,
      "Game Lobby",
      "Browse and configure all coding minigames in one place.",
      shape: ShapeLightFocus.Circle,
      align: ContentAlign.top,
    );
    addTarget(
      "navScan",
      WalkthroughKeys.navScanKey,
      "AI Power-Up",
      "Scan your physical notes and turn them into flashcards instantly.",
      shape: ShapeLightFocus.Circle,
      align: ContentAlign.top,
    );
    addTarget(
      "navExplore",
      WalkthroughKeys.navExploreKey,
      "Content Discovery",
      "Discover new topics and curated study sets for your subjects.",
      shape: ShapeLightFocus.Circle,
      align: ContentAlign.top,
    );
    addTarget(
      "navProfile",
      WalkthroughKeys.navProfileKey,
      "Scholar Profile",
      "Manage your account, customization, and track total progress.",
      shape: ShapeLightFocus.Circle,
      align: ContentAlign.top,
    );

    return targets;
  }

  Widget _buildTutorialContent({
    required String title,
    required String body,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
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
                fontSize: 15,
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

    if (!_activatedTabs.contains(currentIndex)) {
      _activatedTabs.add(currentIndex);
    }

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
