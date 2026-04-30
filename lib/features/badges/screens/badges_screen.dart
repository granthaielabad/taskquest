import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/badges/providers/badge_provider.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(userBadgesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Header ──────────────────────────────────────────────
              Text(
                'Hall of\nAchievements',
                style: AppTheme.headingXL.copyWith(
                  fontSize: 32,
                  height: 0.9,
                  letterSpacing: -1.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Every quest completed is a step to mastery',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              badgesAsync.when(
                data: (badges) {
                  final unlockedCount = badges
                      .where((b) => b.isUnlocked)
                      .length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(context, unlockedCount, badges.length),
                      const SizedBox(height: 32),
                      Text(
                        'ALL BADGES',
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 10,
                          letterSpacing: 1.8,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: badges.length,
                        itemBuilder: (context, index) =>
                            _BadgeCard(badge: badges[index]),
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int unlocked, int total) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL PROGRESS',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.surface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$unlocked / $total Badges',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: theme.colorScheme.surface,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: total > 0 ? unlocked / total : 0,
                  strokeWidth: 6,
                  backgroundColor: theme.colorScheme.surface.withValues(
                    alpha: 0.1,
                  ),
                  valueColor: AlwaysStoppedAnimation(theme.colorScheme.surface),
                ),
              ),
              Text(
                '${(total > 0 ? (unlocked / total) * 100 : 0).round()}%',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.surface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeModel badge;
  const _BadgeCard({required this.badge});

  void _shareBadge() {
    SharePlus.instance.share(
      ShareParams(
        text:
            'I just unlocked the "${badge.title}" badge on TaskQuest! 🏆 ${badge.description} #TaskQuest #CS #Achievement',
        subject: 'TaskQuest Achievement!',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: badge.isUnlocked
            ? colorScheme.surface
            : colorScheme.surface.withValues(alpha: 0.5),
        border: Border.all(
          color: badge.isUnlocked
              ? colorScheme.onSurface.withValues(alpha: 0.1)
              : colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: badge.isUnlocked
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  badge.isUnlocked
                      ? Icons.verified_rounded
                      : Icons.lock_outline_rounded,
                  color: badge.isUnlocked
                      ? colorScheme.surface
                      : colorScheme.onSurface.withValues(alpha: 0.2),
                  size: 24,
                ),
              ),
              if (badge.isUnlocked)
                Transform.translate(
                  offset: const Offset(10, -10),
                  child: GestureDetector(
                    onTap: _shareBadge,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.share_rounded,
                        color: colorScheme.surface,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: badge.isUnlocked
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 8,
              height: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
