import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/explore/screens/explore_content_screen.dart';
import 'package:taskquest/features/explore/screens/leaderboard_screen.dart';
import 'package:taskquest/features/explore/providers/search_provider.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // ── Header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSearchBar(),
              ),
              
              const SizedBox(height: 32),

              if (_query.isEmpty) ...[
                // ── Leaderboard CTA ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildLeaderboardCard(context),
                ),
                
                const SizedBox(height: 32),
                
                // ── Featured Content ────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'FEATURED FOR YOU',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      letterSpacing: 1.8,
                      color: AppTheme.muted,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeaturedScroll(context),
                
                const SizedBox(height: 32),
                
                // ── Trending Topics ─────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'TRENDING TOPICS',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      letterSpacing: 1.8,
                      color: AppTheme.muted,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildTopicGrid(),
                ),
                
                const SizedBox(height: 32),

                // ── Quick Challenges ────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'COMMUNITY CHALLENGES',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      letterSpacing: 1.8,
                      color: AppTheme.muted,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCommunityQuests(),
              ] else ...[
                _buildSearchResultsWidget(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        style: const TextStyle(fontFamily: 'DM Mono', fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search concepts, quests...',
          hintStyle: const TextStyle(fontFamily: 'DM Mono', color: AppTheme.muted, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.muted, size: 20),
          suffixIcon: _query.isNotEmpty 
              ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () => _searchController.clear())
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSearchResultsWidget() {
    final results = ref.watch(searchResultsProvider(_query));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SEARCH RESULTS (${results.length})', style: AppTheme.labelMono),
              GestureDetector(
                onTap: () => _searchController.clear(),
                child: const Text('CLEAR', style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (results.isEmpty)
            const Text('No matches found. Try a different term.', style: AppTheme.bodyMono)
          else
            ...results.map((r) => _buildResultTile(r.title, r.category, r.type)),
        ],
      ),
    );
  }

  Widget _buildResultTile(String title, String tag, String type) {
    IconData typeIcon = Icons.article_outlined;
    if (type == 'QUEST') typeIcon = Icons.bolt_rounded;
    if (type == 'CONCEPT') typeIcon = Icons.psychology_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon, size: 18, color: AppTheme.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tag, style: const TextStyle(fontFamily: 'DM Mono', fontSize: 8, color: AppTheme.muted)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.border, size: 20),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard(BuildContext context) {
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
          color: AppTheme.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.leaderboard_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Global Ranking',
                    style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'See where you stand among scholars',
                    style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: Color(0xFF777777)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedScroll(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildFeaturedCard(
            context,
            title: 'Alan Turing: CS Father',
            tag: 'CS HISTORY',
            image: 'https://picsum.photos/seed/turing/600/400',
          ),
          const SizedBox(width: 16),
          _buildFeaturedCard(
            context,
            title: 'Modern AI & LLMs',
            tag: 'NEW TECH',
            image: 'https://picsum.photos/seed/ai/600/400',
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, {required String title, required String tag, required String image}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExploreContentScreen()),
        );
      },
      child: Container(
        width: 280,
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.black,
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: NetworkImage(image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.5),
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
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.4,
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
        childAspectRatio: 1.3,
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

  Widget _buildCommunityQuests() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildQuestCard('Global Streak Challenge', '12.4k students participating'),
          const SizedBox(height: 12),
          _buildQuestCard('Sorting Algorithm Sprint', 'Complete in under 5 mins'),
        ],
      ),
    );
  }

  Widget _buildQuestCard(String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: const TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: AppTheme.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.border),
        ],
      ),
    );
  }
}
