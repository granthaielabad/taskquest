import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/explore/providers/explore_provider.dart';
import 'package:taskquest/features/explore/providers/bookmark_provider.dart';
import 'package:taskquest/features/explore/services/bookmark_service.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WikiDetailScreen extends ConsumerWidget {
  final String title;

  const WikiDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(wikiSummaryProvider(title));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bookmarkAsync = ref.watch(isBookmarkedProvider(title));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────
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
                        final summary = summaryAsync.value;
                        final bookmark = BookmarkModel(
                          id: title,
                          title: title,
                          type: 'WIKI',
                          url: summary?.contentUrls ?? '',
                          coverImage: summary?.thumbnailUrl,
                          createdAt: DateTime.now(),
                        );
                        await ref.read(bookmarkServiceProvider).toggleBookmark(user.uid, bookmark);
                        ref.invalidate(isBookmarkedProvider(title));
                      }
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: summaryAsync.when(
                data: (summary) => summary?.thumbnailUrl != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            summary!.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: colorScheme.surface,
                              child: Icon(Icons.history_edu_rounded, color: colorScheme.outline, size: 48),
                            ),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: colorScheme.surface,
                        child: Icon(Icons.history_edu_rounded, color: colorScheme.outline, size: 48),
                      ),
                loading: () => Container(color: colorScheme.surface),
                error: (e, s) => Container(color: colorScheme.surface),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'WIKIPEDIA · HISTORY',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      height: 1.1,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  summaryAsync.when(
                    data: (summary) => summary != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                summary.extract,
                                style: TextStyle(
                                  fontFamily: 'DM Mono',
                                  fontSize: 14,
                                  height: 1.6,
                                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final uri = Uri.parse(summary.contentUrls);
                                    try {
                                      final launched = await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                      if (!launched && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Could not launch Wikipedia.')),
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
                                    'READ FULL ON WIKIPEDIA',
                                    style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, letterSpacing: 1.2),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.onSurface,
                                    foregroundColor: colorScheme.surface,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Text('No summary available.', style: TextStyle(fontFamily: 'DM Mono')),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, s) => Center(child: Text('Error: $e')),
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
