import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/explore/providers/search_provider.dart';
import 'package:taskquest/features/explore/providers/explore_provider.dart';
import 'package:taskquest/features/explore/providers/bookmark_provider.dart';
import 'package:taskquest/features/explore/screens/article_detail_screen.dart';
import 'package:taskquest/features/explore/screens/wiki_detail_screen.dart';
import 'package:taskquest/features/explore/screens/pioneers_list_screen.dart';
import 'package:taskquest/features/explore/screens/trending_articles_screen.dart';
import 'package:taskquest/features/explore/services/explore_api_service.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';

  final List<Map<String, String>> _categories = [
    {'label': '#ALL', 'tag': 'programming'},
    {'label': '#AI', 'tag': 'ai'},
    {'label': '#WEB', 'tag': 'webdev'},
    {'label': '#MOBILE', 'tag': 'flutter'},
    {'label': '#SECURITY', 'tag': 'security'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      setState(() => _query = query);
      ref.read(searchQueryProvider.notifier).setQuery(query);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bookmarksAsync = ref.watch(userBookmarksProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                        height: 0.9,
                        letterSpacing: -1.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Discover new concepts and expand your knowledge',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Search Bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSearchBar(context),
              ),

              const SizedBox(height: 24),

              if (_query.isEmpty) ...[
                // ── Daily Byte Banner ──────────────────────────────────
                _buildDailyByte(context),

                const SizedBox(height: 32),

                // ── Trending Categories ──────────────────────────────
                _buildCategoryChips(context),

                const SizedBox(height: 12),

                // ── Trending Tech News (Horizontal) ───────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'TRENDING IN TECH',
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 10,
                              letterSpacing: 1.8,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TrendingArticlesScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'SEE MORE',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 9,
                            letterSpacing: 1.0,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildDynamicArticlesHorizontal(context),

                const SizedBox(height: 36),

                // ── Tech Pioneers & History (Horizontal) ──────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history_edu_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'TECH PIONEERS & HISTORY',
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 10,
                              letterSpacing: 1.8,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PioneersListScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'SEE MORE',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 9,
                            letterSpacing: 1.0,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildTechPioneersList(context),

                const SizedBox(height: 36),

                // ── Computing Timeline (Horizontal) ───────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timeline_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'COMPUTING TIMELINE',
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 10,
                              letterSpacing: 1.8,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildComputingTimeline(context),

                const SizedBox(height: 36),

                // ── Bookmarks (Horizontal) ─────────────────────────────
                bookmarksAsync.when(
                  data: (bookmarks) {
                    if (bookmarks.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'BOOKMARKS',
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 10,
                              letterSpacing: 1.8,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBookmarksList(context, bookmarks),
                        const SizedBox(height: 36),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                ),
              ] else ...[
                _buildSearchResultsWidget(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        style: TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 13,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search concepts, topics, history...',
          hintStyle: TextStyle(
            fontFamily: 'DM Mono',
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDailyByte(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final byteAsync = ref.watch(dailyByteProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.onSurface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: byteAsync.when(
          data: (byte) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DAILY BYTE',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: colorScheme.surface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    byte.year,
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.surface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                byte.title,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: colorScheme.surface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                byte.fact,
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 11,
                  height: 1.5,
                  color: colorScheme.surface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (e, s) => Center(
            child: Text(
              'Failed to load daily byte',
              style: TextStyle(
                color: colorScheme.surface,
                fontFamily: 'DM Mono',
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final selectedTag = ref.watch(trendingCategoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: _categories.map((c) {
          final isSelected = selectedTag == c['tag'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                c['label']!,
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.surface
                      : colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref
                      .read(trendingCategoryProvider.notifier)
                      .setCategory(c['tag']!);
                }
              },
              selectedColor: colorScheme.onSurface,
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.outline,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDynamicArticlesHorizontal(BuildContext context) {
    final articlesAsync = ref.watch(exploreArticlesProvider);

    return articlesAsync.when(
      data: (articles) {
        if (articles.isEmpty) {
          return const Center(
            child: Text(
              'No articles found.',
              style: TextStyle(fontFamily: 'DM Mono'),
            ),
          );
        }
        return SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildHorizontalArticleCard(context, article),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, s) => Center(child: Text('Error loading articles: $e')),
    );
  }

  Widget _buildHorizontalArticleCard(
    BuildContext context,
    ExploreArticle article,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: CachedNetworkImage(
                imageUrl: article.coverImage,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 130,
                  width: double.infinity,
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 130,
                  width: double.infinity,
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.article_rounded,
                    color: colorScheme.outline,
                  ),
                ),
              ),
            ),
            // Text
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.tags.isNotEmpty
                        ? article.tags.first.toUpperCase()
                        : 'TECH',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      height: 1.2,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechPioneersList(BuildContext context) {
    final pioneersAsync = ref.watch(pioneersProvider);

    return pioneersAsync.when(
      data: (state) => SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: state.pioneers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _WikiPioneerCard(title: state.pioneers[index]),
            );
          },
        ),
      ),
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Error loading pioneers',
            style: TextStyle(fontFamily: 'DM Mono', fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarksList(BuildContext context, List bookmarks) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          final b = bookmarks[index];
          return GestureDetector(
            onTap: () {
              if (b.type == 'ARTICLE') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailScreen(
                      article: ExploreArticle(
                        id: int.parse(b.id),
                        title: b.title,
                        description: '',
                        coverImage: b.coverImage ?? '',
                        url: b.url,
                        tags: [],
                      ),
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WikiDetailScreen(title: b.title),
                  ),
                );
              }
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: b.coverImage != null
                        ? Image.network(
                            b.coverImage!,
                            height: 100,
                            width: 140,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 100,
                            width: 140,
                            color: colorScheme.outline.withValues(alpha: 0.1),
                            child: const Icon(Icons.bookmark_rounded),
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            b.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            b.type == 'WIKI' ? 'HISTORY' : 'ARTICLE',
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResultsWidget(BuildContext context) {
    final resultsAsync = ref.watch(exploreSearchProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: resultsAsync.when(
        data: (results) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SEARCH RESULTS (${results.length})',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    letterSpacing: 1.4,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                GestureDetector(
                  onTap: () => _searchController.clear(),
                  child: Text(
                    'CLEAR',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 9,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (results.isEmpty)
              Text(
                'No matches found. Try a different term.',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...results.map((r) => _buildResultTile(context, r)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, SearchResult result) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    IconData typeIcon = Icons.article_outlined;
    if (result.type == 'QUEST') typeIcon = Icons.bolt_rounded;
    if (result.type == 'CONCEPT') typeIcon = Icons.psychology_rounded;
    if (result.type == 'ARTICLE') typeIcon = Icons.newspaper_rounded;
    if (result.type == 'WIKI') typeIcon = Icons.account_balance_rounded;

    return GestureDetector(
      onTap: () async {
        if (result.type == 'ARTICLE' && result.originalData is ExploreArticle) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(
                article: result.originalData as ExploreArticle,
              ),
            ),
          );
        } else if (result.type == 'WIKI') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WikiDetailScreen(title: result.title),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(typeIcon, size: 18, color: colorScheme.onSurface),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.category,
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 8,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.title,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.outline,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComputingTimeline(BuildContext context) {
    final timelineAsync = ref.watch(computingTimelineProvider);

    return timelineAsync.when(
      data: (items) => SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _TimelineCard(item: items[index]);
          },
        ),
      ),
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Failed to load timeline',
            style: TextStyle(fontFamily: 'DM Mono', fontSize: 10),
          ),
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final WikiTimelineItem item;

  const _TimelineCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WikiDetailScreen(title: item.title),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.date,
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'MILESTONE',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.1,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            if (item.description != null)
              Expanded(
                child: Text(
                  item.description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    height: 1.3,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'READ MORE',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WikiPioneerCard extends ConsumerWidget {
  final String title;

  const _WikiPioneerCard({required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(wikiSummaryProvider(title));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WikiDetailScreen(title: title),
          ),
        );
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(20),
        ),
        child: summaryAsync.when(
          data: (summary) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  backgroundImage: summary?.thumbnailUrl != null
                      ? NetworkImage(summary!.thumbnailUrl!)
                      : null,
                  child: summary?.thumbnailUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 36,
                          color: colorScheme.outline,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.1,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'HISTORY',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 8,
                    letterSpacing: 1.0,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const Center(child: Icon(Icons.error_outline)),
        ),
      ),
    );
  }
}
