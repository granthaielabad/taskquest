import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:taskquest/features/explore/services/explore_api_service.dart';
import 'package:taskquest/features/explore/providers/explore_provider.dart';
import 'package:taskquest/features/explore/providers/bookmark_provider.dart';
import 'package:taskquest/features/explore/services/bookmark_service.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final ExploreArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  /// ── HTML to Markdown Converter ─────────────────────────────
  String _processContent(String raw) {
    // If it's already clean markdown (no major HTML tags), return it trimmed
    if (!raw.contains('<h1') && !raw.contains('<p>') && !raw.contains('<div')) {
      return raw.trim();
    }

    // Convert basic HTML tags to Markdown
    String processed = raw
        .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '')
        .replaceAll(RegExp(r'<script.*?>.*?</script>', dotAll: true), '')
        .replaceAll(RegExp(r'<style.*?>.*?</style>', dotAll: true), '');

    processed = processed
        .replaceAllMapped(RegExp(r'<h1.*?>(.*?)</h1>', dotAll: true, caseSensitive: false), (m) => '# ${m[1]}\n\n')
        .replaceAllMapped(RegExp(r'<h2.*?>(.*?)</h2>', dotAll: true, caseSensitive: false), (m) => '## ${m[1]}\n\n')
        .replaceAllMapped(RegExp(r'<h3.*?>(.*?)</h3>', dotAll: true, caseSensitive: false), (m) => '### ${m[1]}\n\n')
        .replaceAllMapped(RegExp(r'<p.*?>(.*?)</p>', dotAll: true, caseSensitive: false), (m) => '${m[1]}\n\n')
        .replaceAllMapped(RegExp(r'<li.*?>(.*?)</li>', dotAll: true, caseSensitive: false), (m) => '* ${m[1]}\n')
        .replaceAllMapped(RegExp(r'<code.*?>(.*?)</code>', dotAll: true, caseSensitive: false), (m) => '`${m[1]}`')
        .replaceAllMapped(RegExp(r'<strong.*?>(.*?)</strong>', dotAll: true, caseSensitive: false), (m) => '**${m[1]}**')
        .replaceAllMapped(RegExp(r'<b.*?>(.*?)</b>', dotAll: true, caseSensitive: false), (m) => '**${m[1]}**')
        .replaceAllMapped(RegExp(r'<em.*?>(.*?)</em>', dotAll: true, caseSensitive: false), (m) => '*${m[1]}*')
        .replaceAllMapped(RegExp(r'<i.*?>(.*?)</i>', dotAll: true, caseSensitive: false), (m) => '*${m[1]}*')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");

    // Remove remaining structural tags but keep the text
    processed = processed.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // CRITICAL: Remove leading indentation that forces Markdown to think the entire article is a code block
    return processed.split('\n').map((line) => line.trimLeft()).join('\n').trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(exploreArticleContentProvider(article.id));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bookmarkAsync = ref.watch(isBookmarkedProvider(article.id.toString()));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: bookmarkAsync.when(
                  data: (isBookmarked) => IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        color: isBookmarked ? colorScheme.primary : Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () async {
                      final user = ref.read(authStateProvider).value;
                      if (user != null) {
                        final bookmark = BookmarkModel(
                          id: article.id.toString(),
                          title: article.title,
                          type: 'ARTICLE',
                          url: article.url,
                          coverImage: article.coverImage,
                          createdAt: DateTime.now(),
                        );
                        await ref.read(bookmarkServiceProvider).toggleBookmark(user.uid, bookmark);
                        ref.invalidate(isBookmarkedProvider(article.id.toString()));
                      }
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    article.coverImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.surface,
                      child: Icon(Icons.image_not_supported_rounded, color: colorScheme.outline),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: article.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 9,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    article.title,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      height: 1.1,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),

                  contentAsync.when(
                    data: (rawMarkdown) {
                      final processedContent = _processContent(rawMarkdown);
                      
                      return MarkdownBody(
                        data: processedContent,
                        selectable: true,
                        builders: {
                          'code': CodeBlockBuilder(isDark: isDark),
                        },
                        onTapLink: (text, href, title) async {
                          if (href != null) {
                            final uri = Uri.parse(href);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          }
                        },
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 14,
                            height: 1.6,
                            color: colorScheme.onSurface.withValues(alpha: 0.85),
                          ),
                          h1: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: colorScheme.onSurface,
                          ),
                          h2: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.onSurface,
                          ),
                          code: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, s) => Center(child: Text('Error: $e')),
                  ),

                  const SizedBox(height: 40),
                  
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(article.url);
                        try {
                          final launched = await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                          if (!launched && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not launch original article.')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error launching URL: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text(
                        'READ ORIGINAL ARTICLE',
                        style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final bool isDark;
  CodeBlockBuilder({required this.isDark});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String content = element.textContent;

    // A real code block usually has multiple lines AND doesn't look like a markdown header
    final bool looksLikeMarkdownText = content.startsWith('#') || content.startsWith('*') || content.length > 500;
    final bool isMultiLine = content.contains('\n');

    if (!isMultiLine || looksLikeMarkdownText) {
      return null; // Let the default styleSheet handle standard text
    }

    final String language = element.attributes['class'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 12),
              child: Text(
                language.replaceAll('language-', '').toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38,
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 12,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
