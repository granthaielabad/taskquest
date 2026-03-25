import 'package:flutter/material.dart';
import 'package:taskquest/core/theme/app_theme.dart';

class Badge {
  final String title;
  final String description;
  final String xp;
  final IconData icon;
  final bool isEarned;

  const Badge({
    required this.title,
    required this.description,
    required this.xp,
    required this.icon,
    required this.isEarned,
  });
}

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const earnedBadges = [
      Badge(
        title: 'First Quest',
        description: 'Complete your\nfirst challenge',
        xp: '+50 XP',
        icon: Icons.star_rounded,
        isEarned: true,
      ),
      Badge(
        title: 'Code Cracker',
        description: 'Finish 5 Code\nBlock sessions',
        xp: '+120 XP',
        icon: Icons.task_alt_rounded,
        isEarned: true,
      ),
      Badge(
        title: 'Flashmaster',
        description: 'Review 50+\nflashcards',
        xp: '+100 XP',
        icon: Icons.style_rounded,
        isEarned: true,
      ),
      Badge(
        title: 'Speed Demon',
        description: 'Finish timed\ntask under 30s',
        xp: '+80 XP',
        icon: Icons.timer_rounded,
        isEarned: true,
      ),
      Badge(
        title: 'Logic Lord',
        description: 'Solve 3\nalgorithm\nchallenges',
        xp: '+150 XP',
        icon: Icons.auto_graph_rounded,
        isEarned: true,
      ),
      Badge(
        title: 'SDLC Pro',
        description: 'Complete all\nSDLC levels',
        xp: '+90 XP',
        icon: Icons.home_repair_service_rounded,
        isEarned: true,
      ),
    ];

    const lockedBadges = [
      Badge(
        title: 'Algorithm Pro',
        description: 'Solve 10\nalgorithm\nproblems',
        xp: '+200 XP',
        icon: Icons.functions_rounded,
        isEarned: false,
      ),
      Badge(
        title: 'Polyglot',
        description: 'Identify 10\nlanguages\ncorrectly',
        xp: '+180 XP',
        icon: Icons.language_rounded,
        isEarned: false,
      ),
      Badge(
        title: 'Streak King',
        description: 'Maintain a 30-\nday streak',
        xp: '+500 XP',
        icon: Icons.local_fire_department_rounded,
        isEarned: false,
      ),
      Badge(
        title: 'AI Scholar',
        description: 'Generate 5 AI\nflashcard decks',
        xp: '+160 XP',
        icon: Icons.psychology_rounded,
        isEarned: false,
      ),
      Badge(
        title: 'Explorer',
        description: 'Read 20\nMultimedia\narticles',
        xp: '+140 XP',
        icon: Icons.explore_rounded,
        isEarned: false,
      ),
      Badge(
        title: 'Top Quester',
        description: 'Reach #1 on\nleaderboard',
        xp: '+1000 XP',
        icon: Icons.emoji_events_rounded,
        isEarned: false,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            // Page header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Badges',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      letterSpacing: -0.78,
                      color: AppTheme.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Earn them by completing challenges',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      letterSpacing: 1.0,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hero: Latest Earned 
            _buildHeroCard(),
            const SizedBox(height: 28),

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterTab('All', active: true),
                  _buildFilterTab('Earned'),
                  _buildFilterTab('Locked'),
                  _buildFilterTab('Rare'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Earned Badges Section
            _buildSectionHeader('Earned Badges'),
            _buildBadgeGrid(earnedBadges),
            const SizedBox(height: 32),

            // Locked Badges Section
            _buildSectionHeader('Locked Badges'),
            _buildBadgeGrid(lockedBadges),
            const SizedBox(height: 32),

            // Next Up Progress
            _buildSectionHeader('Next Up'),
            _buildProgressCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LATEST EARNED',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    letterSpacing: 1.44,
                    color: Color(0x66FFFFFF),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Code Cracker',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.4,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildHeroStat('8', 'Earned'),
                    const SizedBox(width: 14),
                    _buildHeroStat('14', 'Total'),
                    const SizedBox(width: 14),
                    _buildHeroStat('57%', 'Complete'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: -0.32,
            color: Colors.white,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 8,
            letterSpacing: 0.8,
            color: Color(0x59FFFFFF),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(String label, {bool active = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppTheme.black : Colors.white,
        border: Border.all(color: active ? AppTheme.black : AppTheme.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 10,
          letterSpacing: 1.0,
          color: active ? Colors.white : AppTheme.muted,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 10,
          letterSpacing: 1.8,
          color: AppTheme.muted,
        ),
      ),
    );
  }

  Widget _buildBadgeGrid(List<Badge> badges) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 100 / 144,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _buildBadgeCard(badge);
      },
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 17, 11, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: badge.isEarned ? AppTheme.black : AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Opacity(
        opacity: badge.isEarned ? 1.0 : 0.45,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: badge.isEarned ? AppTheme.black : AppTheme.border,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    badge.icon,
                    color: badge.isEarned ? Colors.white : AppTheme.muted,
                    size: 26,
                  ),
                ),
                if (badge.isEarned)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppTheme.black,
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: -0.11,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(
                badge.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 9,
                  height: 1.4,
                  color: AppTheme.muted,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.xp,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontWeight: FontWeight.w500,
                fontSize: 9,
                letterSpacing: 0.54,
                color: badge.isEarned ? AppTheme.black : const Color(0xFFCCCAC4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Algorithm Pro',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: -0.13,
                  color: AppTheme.black,
                ),
              ),
              Text(
                '3 / 10',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: AppTheme.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Solve 7 more algorithm challenges to unlock this badge and earn +200 XP.',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              height: 1.55,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.3,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.black,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}