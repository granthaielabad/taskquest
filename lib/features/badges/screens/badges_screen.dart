import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/badges/providers/badge_provider.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(userBadgesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // ── Header ──────────────────────────────────────────────
              Text(
                'Hall of\nAchievements',
                style: AppTheme.headingXL.copyWith(
                  fontSize: 32,
                  height: 0.9,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Every quest completed is a step to mastery',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  letterSpacing: 0.5,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 32),

              badgesAsync.when(
                data: (badges) {
                  final unlockedCount = badges.where((b) => b.isUnlocked).length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(unlockedCount, badges.length),
                      const SizedBox(height: 32),
                      const Text(
                        'ALL BADGES',
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 10,
                          letterSpacing: 1.8,
                          color: AppTheme.muted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: badges.length,
                        itemBuilder: (context, index) => _BadgeCard(badge: badges[index]),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e'),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int unlocked, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL PROGRESS',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: Color(0xFF777777),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$unlocked / $total Badges',
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Colors.white,
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
                  backgroundColor: const Color(0xFF222222),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              Text(
                '${(total > 0 ? (unlocked / total) * 100 : 0).round()}%',
                style: const TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: badge.isUnlocked ? AppTheme.white : AppTheme.white.withValues(alpha: 0.5),
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: badge.isUnlocked ? AppTheme.black : AppTheme.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              badge.isUnlocked ? Icons.verified_rounded : Icons.lock_outline_rounded,
              color: badge.isUnlocked ? Colors.white : AppTheme.border,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: badge.isUnlocked ? AppTheme.black : AppTheme.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 8,
              height: 1.4,
              color: AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}
