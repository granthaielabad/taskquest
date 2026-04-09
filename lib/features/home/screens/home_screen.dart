import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/home/providers/quest_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/core/utils/xp_utils.dart';
import 'package:taskquest/features/shared/widgets/level_up_dialog.dart';
import 'package:taskquest/features/home/providers/activity_provider.dart';
import 'package:taskquest/features/explore/screens/leaderboard_screen.dart';
import 'package:taskquest/features/games/screens/games_screen.dart';
import 'package:taskquest/features/games/screens/code_blocks_screen.dart';
import 'package:taskquest/features/games/screens/quiz_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(dailyQuestsProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    // ── Listen for Level Up ─────────────────────────────────────
    ref.listen<AsyncValue<UserModel?>>(userProfileProvider, (previous, next) {
      final oldLevel = previous?.value?.level;
      final newLevel = next.value?.level;

      if (oldLevel != null && newLevel != null && newLevel > oldLevel) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => LevelUpDialog(
            newLevel: newLevel,
            rank: XpUtils.getRankTitle(newLevel),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              userProfileAsync.when(
                data: (user) =>
                    _buildUserContent(context, ref, user, questsAsync),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserContent(
    BuildContext context,
    WidgetRef ref,
    UserModel? user,
    AsyncValue<List<QuestModel>> questsAsync,
  ) {
    if (user == null) {
      final theme = Theme.of(context);
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Setting up your profile...',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayName = user.displayName.isNotEmpty
        ? user.displayName
        : 'Scholar';
    final totalXp = user.xp;
    final levelData = XpUtils.getLevelProgress(totalXp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Nav
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GOOD MORNING',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      letterSpacing: 1.4,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${displayName.split(' ').first} 👋',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.4,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildIconButton(
                    context,
                    Icons.notifications_none_rounded,
                    hasBadge: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Streak Banner
        _buildStreakBanner(
          context,
          user.streak,
          levelData['level'] as int,
          totalXp,
          levelData['progress'] as double,
        ),

        const SizedBox(height: 20),

        // Global Ranking (Moved from Explore)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildLeaderboardCard(context),
        ),

        const SizedBox(height: 32),

        // Daily Quest
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'DAILY QUEST',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              letterSpacing: 1.8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Challenges",
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.3,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    _buildStatusBadge(context, questsAsync),
                  ],
                ),
                const SizedBox(height: 10),
                questsAsync.when(
                  data: (quests) => Column(
                    children: quests
                        .map(
                          (q) => _QuestItem(
                            done: q.isCompleted,
                            title: q.title,
                            sub: q.description,
                            xp: q.xpReward,
                            onTap: () {
                              if (!q.isCompleted) {
                                ref
                                    .read(questServiceProvider)
                                    .completeQuest(user.uid, q);
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, s) => Text('Error: $e'),
                ),
                const SizedBox(height: 14),
                _buildProgressIndicator(context, questsAsync),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Game Modes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'GAME MODES',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              letterSpacing: 1.8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildGameModes(context),

        const SizedBox(height: 32),

        // Recent Activity
        _buildRecentActivityHeader(context),
        const SizedBox(height: 10),
        _buildActivityList(context, ref),
      ],
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon, {
    bool hasBadge = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(icon, color: theme.colorScheme.onSurface, size: 16),
          ),
          if (hasBadge)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.onSurface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STREAK',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    letterSpacing: 1.44,
                    color: colorScheme.surface.withOpacity(0.6),
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
                        fontSize: 26,
                        color: colorScheme.surface,
                        letterSpacing: -0.78,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'days',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: colorScheme.surface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                      .asMap()
                      .entries
                      .map((e) {
                        final isToday = e.key == DateTime.now().weekday - 1;
                        return Container(
                          width: 26,
                          height: 26,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            color: isToday
                                ? colorScheme.surface
                                : colorScheme.surface.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: Text(
                              e.value,
                              style: TextStyle(
                                fontFamily: 'DM Mono',
                                fontSize: 9,
                                color: isToday
                                    ? colorScheme.onSurface
                                    : colorScheme.surface.withOpacity(0.8),
                              ),
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Lvl $level',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: colorScheme.surface,
                    letterSpacing: -0.32,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$xp XP',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    letterSpacing: 0.9,
                    color: colorScheme.surface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: colorScheme.surface.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(colorScheme.surface),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.leaderboard_rounded,
                color: theme.colorScheme.surface,
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
                      color: theme.colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'See where you stand among scholars',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 9,
                      color: theme.colorScheme.surface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.surface.withOpacity(0.5),
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
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.onSurface),
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildGameModes(BuildContext context) {
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
                  builder: (context) => const CodeBlocksScreen(),
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
                MaterialPageRoute(builder: (context) => const QuizScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
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
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              'SEE ALL',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 9,
                letterSpacing: 1.0,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                decoration: TextDecoration.underline,
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
                    ? colorScheme.surface.withOpacity(0.4)
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
                      ? colorScheme.surface.withOpacity(0.6)
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
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
