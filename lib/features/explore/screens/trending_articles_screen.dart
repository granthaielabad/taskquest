import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/explore/providers/explore_provider.dart';
import 'package:taskquest/features/explore/screens/article_detail_screen.dart';
import 'package:taskquest/features/explore/services/explore_api_service.dart';

class TrendingArticlesScreen extends ConsumerWidget {
  const TrendingArticlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(exploreArticlesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'TRENDING TECH',
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 12,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: articlesAsync.when(
        data: (articles) => ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            return _ArticleListTile(article: articles[index]);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading articles: $e')),
      ),
    );
  }
}

class _ArticleListTile extends StatelessWidget {
  final ExploreArticle article;

  const _ArticleListTile({required this.article});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: article.coverImage,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 100,
                  height: 100,
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 100,
                  height: 100,
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  child: const Icon(Icons.article_rounded),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.tags.isNotEmpty
                        ? article.tags.first.toUpperCase()
                        : 'TECH',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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
}
