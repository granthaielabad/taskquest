import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/home/providers/quest_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/games/models/game_models.dart';
import 'package:taskquest/core/utils/xp_utils.dart';
import 'package:taskquest/features/shared/widgets/level_up_dialog.dart';
import 'package:taskquest/features/home/providers/activity_provider.dart';
import 'package:taskquest/features/explore/screens/leaderboard_screen.dart';
import 'package:taskquest/features/home/screens/notifications_screen.dart';
import 'package:taskquest/features/games/screens/games_screen.dart';
import 'package:taskquest/features/games/screens/code_blocks_gameplay_screen.dart';
import 'package:taskquest/features/games/screens/quiz_gameplay_screen.dart';
import 'package:taskquest/features/games/screens/game_lobby_screen.dart';
import 'package:taskquest/features/games/screens/sdlc_gameplay_screen.dart';
import 'package:taskquest/features/games/screens/solve_algorithm_gameplay_screen.dart';
import 'package:taskquest/features/settings/screens/notifications_screen.dart';

import 'package:taskquest/features/badges/screens/badges_screen.dart';
import 'package:taskquest/features/home/screens/all_activity_screen.dart';
import 'package:taskquest/core/providers/tutorial_provider.dart';
import 'package:taskquest/core/providers/theme_provider.dart';

import 'package:taskquest/features/shared/widgets/scale_on_tap.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(dailyQuestsProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    // ── Optimized Selectors ────────────────────────────────────
    final displayName = ref.watch(
      userProfileProvider.select((u) => u.value?.displayName ?? 'Scholar'),
    );
    final xp = ref.watch(userProfileProvider.select((u) => u.value?.xp ?? 0));
    final streak = ref.watch(
      userProfileProvider.select((u) => u.value?.streak ?? 0),
    );
    final level = ref.watch(
      userProfileProvider.select((u) => u.value?.level ?? 1),
    );
    final unlockedCount = ref.watch(
      userProfileProvider.select((u) => u.value?.unlockedBadges.length ?? 0),
    );
    final userEmail = ref.watch(
      userProfileProvider.select((u) => u.value?.email ?? ''),
    );
    final userId = ref.watch(
      userProfileProvider.select((u) => u.value?.uid ?? ''),
    );

    // ── Listen for Level Up ─────────────────────────────────────
    ref.listen<int?>(userProfileProvider.select((u) => u.value?.level), (
      previous,
      next,
    ) {
      if (previous != null && next != null && next > previous) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              LevelUpDialog(newLevel: next, rank: XpUtils.getRankTitle(next)),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildUserContent(
                    context,
                    ref,
                    displayName,
                    xp,
                    streak,
                    level,
                    unlockedCount,
                    userEmail,
                    userId,
                    questsAsync,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserContent(
    BuildContext context,
    WidgetRef ref,
    String displayName,
    int xp,
    int streak,
    int level,
    int unlockedCount,
    String email,
    String userId,
    AsyncValue<List<QuestModel>> questsAsync,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final levelData = XpUtils.getLevelProgress(xp);
    final progress = (levelData['progress'] as double).clamp(0.0, 1.0);

    final hour = DateTime.now().hour;
    String greeting = 'GOOD MORNING,';
    if (hour >= 12 && hour < 17) {
      greeting = 'GOOD AFTERNOON,';
    } else if (hour >= 17) {
      greeting = 'GOOD EVENING,';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  key: WalkthroughKeys.greetingKey,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        letterSpacing: -0.84,
                        color: colorScheme.onSurface,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                key: WalkthroughKeys.notificationKey,
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: colorScheme.onSurface,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Streak Banner ───────────────────────────────────────
        _buildStreakBanner(context, streak, level, xp, progress),

        const SizedBox(height: 32),

        // ── Leaderboard Link ────────────────────────────────────
        Padding(
          key: WalkthroughKeys.leaderboardCardKey,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildLeaderboardCard(context),
        ),

        const SizedBox(height: 16),

        // ── Badges Link ─────────────────────────────────────────
        Padding(
          key: WalkthroughKeys.badgesCardKey,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildBadgesCard(context, unlockedCount),
        ),

        const SizedBox(height: 40),

        // ── Today's Challenges ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY\'S CHALLENGES',
                key: WalkthroughKeys.challengesKey,
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  letterSpacing: 1.8,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              _buildStatusBadge(context, questsAsync),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _buildProgressIndicator(context, questsAsync),
                const SizedBox(height: 24),
                questsAsync.when(
                  data: (quests) {
                    if (quests.isEmpty) {
                      return const Text(
                        'No quests available. Check back soon!',
                        style: TextStyle(fontFamily: 'DM Mono', fontSize: 11),
                      );
                    }
                    return Column(
                      children: quests.map((q) {
                        return _QuestItem(
                          done: q.isCompleted,
                          title: q.title,
                          sub: q.description,
                          xp: q.xpReward,
                          onTap: () {
                            if (q.isCompleted) return;

                            // Map categories to Tab Indices to keep BottomNav visible
                            final cat = q.category.toUpperCase();
                            final nav = ref.read(navigationIndexProvider.notifier);

                            if (cat == 'GAMES' || cat == 'CODING' || cat == 'CS BASICS' || cat == 'QUIZ' || cat == 'LOGIC' || cat == 'ARCHITECTURE') {
                              nav.setIndex(1); // Switch to Games Tab
                            } else if (cat == 'STUDY' || cat == 'AI') {
                              nav.setIndex(2); // Switch to Scan/AI Tab
                            } else if (cat == 'SOCIAL') {
                              // Switch to Explore Tab AND show Leaderboard overlay
                              nav.setIndex(3);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                              );
                            } else if (cat == 'EXPLORE') {
                              nav.setIndex(3); // Switch to Explore Tab
                            }
                          },
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error loading quests: $e'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 40),

        // ── Game Modes ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'GAME MODES',
            key: WalkthroughKeys.gamesKey,
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              letterSpacing: 1.8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildGameModes(context, ref),

        const SizedBox(height: 40),

        // ── Recent Activity ────────────────────────────────────
        _buildRecentActivityHeader(context),
        const SizedBox(height: 16),
        _buildActivityList(context, ref),
      ],
    );
  }

  Widget _buildStreakBanner(
    BuildContext context,
    int streak,
    int level,
    int xp,
    double progress,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        key: WalkthroughKeys.streakKey,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.onSurface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Streak Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT STREAK',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 9,
                        letterSpacing: 1.44,
                        color: colorScheme.surface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$streak',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                            color: colorScheme.surface,
                            letterSpacing: -0.78,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'days',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: colorScheme.surface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Right: Level & XP Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Lvl $level',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: colorScheme.surface,
                        letterSpacing: -0.32,
                      ),
                    ),
                    const SizedBox(height: 2),
                    TweenAnimationBuilder<int>(
                      duration: const Duration(seconds: 1),
                      tween: IntTween(begin: 0, end: xp),
                      curve: Curves.easeOutExpo,
                      builder: (context, value, child) {
                        return Text(
                          '$value XP',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 10,
                            letterSpacing: 0.9,
                            color: colorScheme.surface.withValues(alpha: 0.5),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 90,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: colorScheme.surface.withValues(
                            alpha: 0.1,
                          ),
                          valueColor: AlwaysStoppedAnimation(
                            colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Bottom: Days Row (Fully visible, no scroll)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map(
                (e) {
                  final isToday = e.key == DateTime.now().weekday - 1;
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isToday
                          ? colorScheme.surface
                          : colorScheme.surface.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 10,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday
                              ? colorScheme.onSurface
                              : colorScheme.surface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ScaleOnTap(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.onSurface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.leaderboard_rounded,
                color: colorScheme.surface,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Global Ranking',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'See where you stand among scholars',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 9,
                      color: colorScheme.surface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.surface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesCard(BuildContext context, int unlockedCount) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ScaleOnTap(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BadgesScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.stars_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hall of Achievements',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$unlockedCount badges unlocked',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 9,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    AsyncValue<List<QuestModel>> questsAsync,
  ) {
    final theme = Theme.of(context);
    return questsAsync.maybeWhen(
      data: (quests) {
        final done = quests.where((q) => q.isCompleted).length;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$done / ${quests.length} done',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 9,
              letterSpacing: 0.9,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    AsyncValue<List<QuestModel>> questsAsync,
  ) {
    final theme = Theme.of(context);
    return questsAsync.maybeWhen(
      data: (quests) {
        final totalXp = quests.fold(0, (sum, q) => sum + q.xpReward);
        final currentXp = quests
            .where((q) => q.isCompleted)
            .fold(0, (sum, q) => sum + q.xpReward);
        final progress = totalXp > 0 ? currentXp / totalXp : 0.0;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DAILY PROGRESS',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    letterSpacing: 0.9,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '$currentXp / $totalXp XP',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: theme.colorScheme.outline,
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildGameModes(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GamePill(
            title: 'Flashcards',
            desc: 'Manual or AI-generated',
            tag: 'AI ✦ Featured',
            icon: Icons.style,
            isFeatured: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GamesScreen()),
              );
            },
          ),
          const SizedBox(width: 10),
          _GamePill(
            title: 'Code Blocks',
            desc: 'Drag & drop syntax',
            tag: 'Interactive',
            icon: Icons.code,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GameLobbyScreen(
                    title: 'Code Blocks',
                    description:
                        'Fill in the blanks — drag the correct code blocks into the missing slots to complete working programs. Race against the clock!',
                    icon: Icons.code_rounded,
                    stats: [
                      {'value': '6', 'label': 'PUZZLES'},
                      {'value': '190', 'label': 'BEST XP'},
                      {'value': '+150', 'label': 'XP REWARD'},
                      {'value': '6m', 'label': 'EST. TIME'},
                    ],
                    configOptions: {
                      'Language': ['Python', 'JavaScript', 'Java', 'C++'],
                      'Difficulty': ['Beginner', 'Intermediate', 'Advanced'],
                      'Topic': ['All Topics', 'Loops', 'Functions', 'OOP'],
                    },
                    startButtonText: 'Start Coding',
                    gameScreen: CodeBlocksGameplayScreen(),
                    gameType: GameType.codeBlocks,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          _GamePill(
            title: 'Which Lang?',
            desc: 'Identify from clues',
            tag: 'Quiz',
            icon: Icons.question_mark_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GameLobbyScreen(
                    title: 'Which Lang?',
                    description:
                        'Identify programming languages from clues — syntax snippets, descriptions, or fun facts. How many can you get right?',
                    icon: Icons.quiz_rounded,
                    stats: [
                      {'value': '10', 'label': 'QUESTIONS'},
                      {'value': '8/10', 'label': 'BEST SCORE'},
                      {'value': '+100', 'label': 'XP REWARD'},
                      {'value': '4m', 'label': 'EST. TIME'},
                    ],
                    configOptions: {
                      'Clue Type': [
                        'Mix of All',
                        'Syntax Only',
                        'Description',
                        'Fun Facts',
                      ],
                      'Language Pool': [
                        'All (20 langs)',
                        'Popular 10',
                        'Beginner Set',
                      ],
                      'Time per Question': ['45s', '30s', '15s'],
                    },
                    startButtonText: 'Start Quiz',
                    gameScreen: QuizGameplayScreen(),
                    gameType: GameType.quiz,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          _GamePill(
            title: 'SDLC Seq',
            desc: 'Arrange lifecycle',
            tag: 'Logic',
            icon: Icons.reorder_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameLobbyScreen(
                    title: 'SDLC Sequence',
                    description:
                        'Master the Software Development Life Cycle by arranging phases in the correct logical order for different methodologies.',
                    icon: Icons.reorder_rounded,
                    stats: const [
                      {'value': '5', 'label': 'SEQUENCES'},
                      {'value': '4/5', 'label': 'ACCURACY'},
                      {'value': '+120', 'label': 'XP REWARD'},
                      {'value': '5m', 'label': 'EST. TIME'},
                    ],
                    configOptions: const {
                      'Complexity': ['Standard', 'Advanced', 'Industry'],
                    },
                    startButtonText: 'Start Sorting',
                    gameScreen: SdlcGameplayScreen(),
                    gameType: GameType.sdlc,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          _GamePill(
            title: 'Algorithm',
            desc: 'Solve trace logic',
            tag: 'Advanced',
            icon: Icons.functions_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameLobbyScreen(
                    title: 'Algorithm Trace',
                    description:
                        'Analyze pseudocode and determine the output or time complexity. Perfect for technical interview prep!',
                    icon: Icons.functions_rounded,
                    stats: const [
                      {'value': '8', 'label': 'PROBLEMS'},
                      {'value': '12ms', 'label': 'AVG SPEED'},
                      {'value': '+200', 'label': 'XP REWARD'},
                      {'value': '8m', 'label': 'EST. TIME'},
                    ],
                    configOptions: const {
                      'Difficulty': ['Beginner', 'Advanced'],
                      'Topic': [
                        'All',
                        'Data Structures',
                        'Sort/Search',
                        'Recursion',
                      ],
                    },
                    startButtonText: 'Start Solving',
                    gameScreen: SolveAlgorithmGameplayScreen(),
                    gameType: GameType.algorithm,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      key: WalkthroughKeys.recentActivityKey,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'RECENT ACTIVITY',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              letterSpacing: 1.8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllActivityScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'SEE ALL',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 9,
                  letterSpacing: 1.0,
                  color: colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No recent activity yet. Start your first quest!',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }
          return Column(
            children: activities.map((activity) {
              IconData icon = Icons.bolt_rounded;
              bool isDark = false;
              if (activity.type == ActivityType.scan) {
                icon = Icons.document_scanner_rounded;
              }
              if (activity.type == ActivityType.game) {
                icon = Icons.videogame_asset_rounded;
                isDark = true;
              }
              if (activity.type == ActivityType.study) {
                icon = Icons.menu_book_rounded;
              }

              // Simple time formatting
              final now = DateTime.now();
              final diff = now.difference(activity.timestamp);
              String timeStr = 'Just now';
              if (diff.inMinutes > 0) timeStr = '${diff.inMinutes}m ago';
              if (diff.inHours > 0) timeStr = '${diff.inHours}h ago';
              if (diff.inDays > 0) timeStr = '${diff.inDays}d ago';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ActivityItem(
                  icon: icon,
                  title: activity.title,
                  sub: activity.subtitle,
                  xp: '+${activity.xpReward} XP',
                  time: timeStr,
                  isDarkIcon: isDark,
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }
}

class _QuestItem extends StatelessWidget {
  final bool done;
  final String title;
  final String sub;
  final int xp;
  final VoidCallback onTap;
  const _QuestItem({
    required this.done,
    required this.title,
    required this.sub,
    required this.xp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: done ? colorScheme.onSurface : Colors.transparent,
                border: Border.all(
                  color: done ? colorScheme.onSurface : colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: done
                  ? Icon(Icons.check, color: colorScheme.surface, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: done
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+$xp XP',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 10,
                letterSpacing: 0.6,
                color: done
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
                fontWeight: done ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamePill extends StatelessWidget {
  final String title;
  final String desc;
  final String tag;
  final IconData icon;
  final bool isFeatured;
  final VoidCallback onTap;

  const _GamePill({
    required this.title,
    required this.desc,
    required this.tag,
    required this.icon,
    this.isFeatured = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFeatured ? 150 : 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isFeatured ? colorScheme.onSurface : colorScheme.surface,
          border: Border.all(
            color: isFeatured ? colorScheme.onSurface : colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isFeatured
                    ? colorScheme.surface.withOpacity(0.1)
                    : theme.scaffoldBackgroundColor,
                border: isFeatured
                    ? null
                    : Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isFeatured ? colorScheme.surface : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: isFeatured ? colorScheme.surface : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 9,
                height: 1.4,
                color: isFeatured
                    ? colorScheme.surface.withValues(alpha: 0.4)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: isFeatured
                    ? colorScheme.surface.withOpacity(0.1)
                    : theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 8,
                  letterSpacing: 0.08,
                  color: isFeatured
                      ? colorScheme.surface.withValues(alpha: 0.6)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final String xp;
  final String time;
  final bool isDarkIcon;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.sub,
    required this.xp,
    required this.time,
    this.isDarkIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDarkIcon
                  ? colorScheme.onSurface
                  : theme.scaffoldBackgroundColor,
              border: Border.all(
                color: isDarkIcon ? colorScheme.onSurface : colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isDarkIcon ? colorScheme.surface : colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                xp,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 9,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
