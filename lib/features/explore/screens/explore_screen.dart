import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/explore/screens/explore_content_screen.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                'Learning\nExplorer',
                style: AppTheme.headingXL.copyWith(
                  fontSize: 32,
                  height: 0.9,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Discover new concepts and expand your knowledge',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  letterSpacing: 0.5,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 32),

              // Search Bar
              _buildSearchBar(),
              
              const SizedBox(height: 32),
              
              // Featured Card
              _buildFeaturedCard(context),
              
              const SizedBox(height: 32),
              
              const Text(
                'TRENDING TOPICS',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  letterSpacing: 1.8,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 16),
              _buildTopicGrid(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.search_rounded, color: AppTheme.muted, size: 20),
          SizedBox(width: 12),
          Text(
            'Search concepts, docs...',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 12,
              color: AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExploreContentScreen()),
        );
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppTheme.black,
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: const NetworkImage('https://picsum.photos/seed/tech/600/300'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NEW · 8 min read',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'AI Scholar: Mastering LLMs',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.44,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicGrid() {
    final topics = [
      {'title': 'Data Structures', 'icon': Icons.account_tree_rounded},
      {'title': 'Algorithms', 'icon': Icons.psychology_rounded},
      {'title': 'Cloud Computing', 'icon': Icons.cloud_queue_rounded},
      {'title': 'Cybersecurity', 'icon': Icons.security_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final t = topics[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(t['icon'] as IconData, color: AppTheme.black, size: 24),
              Text(
                t['title'] as String,
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
