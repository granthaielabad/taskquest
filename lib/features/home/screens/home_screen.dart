import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/home/providers/quest_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/core/utils/xp_utils.dart';
import 'package:taskquest/features/shared/widgets/level_up_dialog.dart';
import 'package:taskquest/features/home/providers/activity_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(dailyQuestsProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

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
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              
              userProfileAsync.when(
                data: (user) => _buildUserContent(context, ref, user, questsAsync),
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: CircularProgressIndicator(),
                )),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserContent(BuildContext context, WidgetRef ref, UserModel? user, AsyncValue<List<QuestModel>> questsAsync) {
    if (user == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Setting up your profile...', 
                style: TextStyle(fontFamily: 'DM Mono', fontSize: 12, color: AppTheme.muted)),
            ],
          ),
        ),
      );
    }

    final displayName = user.displayName.isNotEmpty ? user.displayName : 'Scholar';
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
                  const Text('GOOD MORNING',
                      style: TextStyle(fontFamily: 'DM Mono', fontSize: 10,
                          letterSpacing: 1.4, color: AppTheme.muted)),
                  const SizedBox(height: 2),
                  Text('${displayName.split(' ').first} 👋',
                      style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800,
                          fontSize: 20, letterSpacing: -0.4, color: AppTheme.black)),
                ],
              ),
              Row(children: [
                _buildIconButton(Icons.notifications_none_rounded, hasBadge: true),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Streak Banner
        _buildStreakBanner(user.streak, levelData['level'] as int, totalXp, levelData['progress'] as double),
        
        const SizedBox(height: 20),

        // Daily Quest
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('DAILY QUEST',
              style: TextStyle(fontFamily: 'DM Mono', fontSize: 10,
                  letterSpacing: 1.8, color: AppTheme.muted)),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("Today's Challenges",
                      style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800,
                          fontSize: 15, letterSpacing: -0.3, color: AppTheme.black)),
                  _buildStatusBadge(questsAsync),
                ]),
                const SizedBox(height: 10),
                questsAsync.when(
                  data: (quests) => Column(
                    children: quests.map((q) => _QuestItem(
                      done: q.isCompleted,
                      title: q.title,
                      sub: q.description,
                      xp: q.xpReward,
                      onTap: () {
                        if (!q.isCompleted) {
                          ref.read(questServiceProvider).completeQuest(user.uid, q);
                        }
                      },
                    )).toList(),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, s) => Text('Error: $e'),
                ),
                const SizedBox(height: 14),
                _buildProgressIndicator(questsAsync),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Game Modes
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('GAME MODES',
              style: TextStyle(fontFamily: 'DM Mono', fontSize: 10,
                  letterSpacing: 1.8, color: AppTheme.muted)),
        ),
        const SizedBox(height: 10),
        _buildGameModes(),
        
        const SizedBox(height: 20),

        // Recent Activity
        _buildRecentActivityHeader(),
        const SizedBox(height: 10),
        _buildActivityList(ref),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, {bool hasBadge = false}) {
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Center(child: Icon(icon, color: AppTheme.black, size: 16)),
          if (hasBadge)
            Positioned(
              top: 8, right: 8,
              child: Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStreakBanner(int streak, int level, int xp, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.black,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CURRENT STREAK',
                    style: TextStyle(fontFamily: 'DM Mono', fontSize: 9,
                        letterSpacing: 1.44, color: Color(0x66FFFFFF))),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('$streak', style: const TextStyle(fontFamily: 'Syne',
                        fontWeight: FontWeight.w800, fontSize: 26,
                        color: Colors.white, letterSpacing: -0.78)),
                    const SizedBox(width: 4),
                    const Text('days', style: TextStyle(fontFamily: 'Syne',
                        fontWeight: FontWeight.w600, fontSize: 13,
                        color: Color(0x66FFFFFF))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: ['M','T','W','T','F','S','S'].asMap().entries.map((e) {
                    final isToday = e.key == DateTime.now().weekday - 1;
                    return Container(
                      width: 26, height: 26, margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: isToday ? Colors.white : const Color(0x2EFFFFFF),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(child: Text(e.value,
                          style: TextStyle(fontFamily: 'DM Mono', fontSize: 9,
                              color: isToday ? AppTheme.black : const Color(0xCCFFFFFF)))),
                    );
                  }).toList(),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Lvl $level', style: const TextStyle(fontFamily: 'Syne',
                    fontWeight: FontWeight.w800, fontSize: 16,
                    color: Colors.white, letterSpacing: -0.32)),
                const SizedBox(height: 2),
                Text('$xp XP', style: const TextStyle(fontFamily: 'DM Mono', fontSize: 9,
                    letterSpacing: 0.9, color: Color(0x59FFFFFF))),
                const SizedBox(height: 8),
                SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
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

  Widget _buildStatusBadge(AsyncValue<List<QuestModel>> questsAsync) {
    return questsAsync.maybeWhen(
      data: (quests) {
        final done = quests.where((q) => q.isCompleted).length;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.background,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('$done / ${quests.length} done',
              style: const TextStyle(fontFamily: 'DM Mono', fontSize: 9,
                  letterSpacing: 0.9, color: AppTheme.muted)),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildProgressIndicator(AsyncValue<List<QuestModel>> questsAsync) {
    return questsAsync.maybeWhen(
      data: (quests) {
        final totalXp = quests.fold(0, (sum, q) => sum + q.xpReward);
        final currentXp = quests.where((q) => q.isCompleted).fold(0, (sum, q) => sum + q.xpReward);
        final progress = totalXp > 0 ? currentXp / totalXp : 0.0;

        return Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('DAILY PROGRESS', style: TextStyle(fontFamily: 'DM Mono',
                  fontSize: 9, letterSpacing: 0.9, color: AppTheme.muted)),
              Text('$currentXp / $totalXp XP', style: const TextStyle(fontFamily: 'DM Mono',
                  fontSize: 9, fontWeight: FontWeight.w500, color: AppTheme.black)),
            ]),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppTheme.border,
                valueColor: const AlwaysStoppedAnimation(AppTheme.black),
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildGameModes() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _GamePill(
            title: 'Flashcards',
            desc: 'Manual or AI-generated',
            tag: 'AI ✦ Featured',
            icon: Icons.style,
            isFeatured: true,
          ),
          SizedBox(width: 10),
          _GamePill(
            title: 'Code Blocks',
            desc: 'Drag & drop syntax',
            tag: 'Interactive',
            icon: Icons.code,
          ),
          SizedBox(width: 10),
          _GamePill(
            title: 'Which Lang?',
            desc: 'Identify from clues',
            tag: 'Quiz',
            icon: Icons.question_mark_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('RECENT ACTIVITY',
              style: TextStyle(fontFamily: 'DM Mono', fontSize: 10,
                  letterSpacing: 1.8, color: AppTheme.muted)),
          GestureDetector(
            onTap: () {},
            child: const Text('SEE ALL',
                style: TextStyle(fontFamily: 'DM Mono', fontSize: 9,
                    letterSpacing: 1.0, color: AppTheme.dimmed,
                    decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No recent activity yet. Start your first quest!', 
                  style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: AppTheme.muted)),
              ),
            );
          }
          return Column(
            children: activities.map((activity) {
              IconData icon = Icons.bolt_rounded;
              bool isDark = false;
              if (activity.type == ActivityType.scan) icon = Icons.document_scanner_rounded;
              if (activity.type == ActivityType.game) {
                icon = Icons.videogame_asset_rounded;
                isDark = true;
              }
              if (activity.type == ActivityType.study) icon = Icons.menu_book_rounded;

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
  const _QuestItem({required this.done, required this.title,
    required this.sub, required this.xp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: done ? AppTheme.black : Colors.transparent,
              border: Border.all(color: done ? AppTheme.black : AppTheme.dimmed),
              borderRadius: BorderRadius.circular(6),
            ),
            child: done ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(
              fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 13,
              color: done ? AppTheme.dimmed : AppTheme.black,
              decoration: done ? TextDecoration.lineThrough : null,
            )),
            Text(sub, style: const TextStyle(fontFamily: 'DM Mono',
                fontSize: 10, color: AppTheme.muted)),
          ])),
          Text('+$xp XP', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10,
              letterSpacing: 0.6, color: done ? AppTheme.muted : AppTheme.black,
              fontWeight: done ? FontWeight.w400 : FontWeight.w500)),
        ]),
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

  const _GamePill({
    required this.title,
    required this.desc,
    required this.tag,
    required this.icon,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFeatured ? 150 : 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFeatured ? AppTheme.black : AppTheme.white,
        border: Border.all(color: isFeatured ? AppTheme.black : AppTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: isFeatured ? Colors.white.withValues(alpha: 0.1) : AppTheme.background,
              border: isFeatured ? null : Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: isFeatured ? Colors.white : AppTheme.black),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(
            fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 12,
            color: isFeatured ? Colors.white : AppTheme.black,
          )),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(
            fontFamily: 'DM Mono', fontSize: 9, height: 1.4,
            color: isFeatured ? Colors.white.withValues(alpha: 0.4) : AppTheme.muted,
          )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isFeatured ? Colors.white.withValues(alpha: 0.1) : AppTheme.background,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(tag.toUpperCase(), style: TextStyle(
              fontFamily: 'DM Mono', fontSize: 8, letterSpacing: 0.08,
              color: isFeatured ? Colors.white.withValues(alpha: 0.6) : AppTheme.muted,
            )),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isDarkIcon ? AppTheme.black : AppTheme.background,
              border: Border.all(color: isDarkIcon ? AppTheme.black : AppTheme.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: isDarkIcon ? Colors.white : AppTheme.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                  fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 12,
                  color: AppTheme.black,
                )),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(
                  fontFamily: 'DM Mono', fontSize: 10, color: AppTheme.muted,
                )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(xp, style: const TextStyle(
                fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 13,
                color: AppTheme.black,
              )),
              const SizedBox(height: 3),
              Text(time, style: const TextStyle(
                fontFamily: 'DM Mono', fontSize: 9, color: AppTheme.dimmed,
              )),
            ],
          ),
        ],
      ),
    );
  }
}
