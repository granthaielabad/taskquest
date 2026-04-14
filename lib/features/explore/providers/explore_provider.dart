import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/explore/services/explore_api_service.dart';

final exploreApiServiceProvider = Provider<ExploreApiService>((ref) {
  return ExploreApiService();
});

class TrendingCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'programming';

  void setCategory(String category) {
    state = category;
  }
}

final trendingCategoryProvider =
    NotifierProvider<TrendingCategoryNotifier, String>(() {
      return TrendingCategoryNotifier();
    });

final exploreArticlesProvider =
    FutureProvider.autoDispose<List<ExploreArticle>>((ref) async {
      final category = ref.watch(trendingCategoryProvider);
      return ref
          .watch(exploreApiServiceProvider)
          .fetchTechArticles(tag: category);
    });

final exploreArticleContentProvider = FutureProvider.family<String, int>((
  ref,
  id,
) async {
  return ref.watch(exploreApiServiceProvider).fetchArticleContent(id);
});

final wikiSummaryProvider = FutureProvider.family<WikiPageSummary?, String>((
  ref,
  title,
) async {
  return ref.watch(exploreApiServiceProvider).fetchWikiSummary(title);
});

// ── Pioneers State ──────────────────────────────────────────

class PioneersState {
  final List<String> pioneers;
  final String? continueToken;
  final String category;
  final String searchQuery;
  final bool isLoadingMore;

  PioneersState({
    required this.pioneers,
    this.continueToken,
    required this.category,
    required this.searchQuery,
    this.isLoadingMore = false,
  });

  PioneersState copyWith({
    List<String>? pioneers,
    String? continueToken,
    String? category,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return PioneersState(
      pioneers: pioneers ?? this.pioneers,
      continueToken: continueToken ?? this.continueToken,
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class PioneersNotifier extends AsyncNotifier<PioneersState> {
  @override
  FutureOr<PioneersState> build() async {
    final response = await ref
        .read(exploreApiServiceProvider)
        .fetchPioneersPaginated();
    return PioneersState(
      pioneers: response.members,
      continueToken: response.continueToken,
      category: 'Category:Computer_scientists',
      searchQuery: '',
    );
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.continueToken == null ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final response = await ref
          .read(exploreApiServiceProvider)
          .fetchPioneersPaginated(
            category: currentState.category,
            continueToken: currentState.continueToken,
          );

      state = AsyncData(
        currentState.copyWith(
          pioneers: [...currentState.pioneers, ...response.members],
          continueToken: response.continueToken,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setCategory(String category) async {
    state = const AsyncLoading();
    try {
      final response = await ref
          .read(exploreApiServiceProvider)
          .fetchPioneersPaginated(category: category);
      state = AsyncData(
        PioneersState(
          pioneers: response.members,
          continueToken: response.continueToken,
          category: category,
          searchQuery: '',
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void setSearchQuery(String query) {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(searchQuery: query));
    }
  }
}

final pioneersProvider =
    AsyncNotifierProvider<PioneersNotifier, PioneersState>(() {
      return PioneersNotifier();
    });

final computingTimelineProvider =
    FutureProvider<List<WikiTimelineItem>>((ref) async {
      try {
        final items =
            await ref.watch(exploreApiServiceProvider).fetchComputingTimeline();
        if (items.isNotEmpty) return items;
      } catch (_) {}

      // Fallback timeline
      return [
        WikiTimelineItem(title: 'World Wide Web', date: '1990-12-25'),
        WikiTimelineItem(title: 'C++ Release', date: '1985-10-01'),
        WikiTimelineItem(title: 'Apple I', date: '1976-04-11'),
        WikiTimelineItem(title: 'C Programming Language', date: '1972-01-01'),
        WikiTimelineItem(title: 'ARPANET', date: '1969-10-29'),
        WikiTimelineItem(title: 'COBOL', date: '1959-01-01'),
        WikiTimelineItem(title: 'ENIAC', date: '1946-02-15'),
      ];
    });

// ── Daily Byte Data (Dynamic via Wikidata) ──────────────────
final dailyByteProvider = FutureProvider<WikiHistoryEvent>((ref) async {
  final event = await ref.watch(exploreApiServiceProvider).fetchDailyByte();

  if (event != null) return event;

  // Fallback if Wikidata fails or returns empty
  final fallbacks = [
    WikiHistoryEvent(
      title: 'ENIAC Unveiled',
      fact:
          'In 1946, the first general-purpose electronic computer was dedicated at UPenn.',
      year: '1946',
    ),
    WikiHistoryEvent(
      title: 'The First Mouse',
      fact:
          'Douglas Engelbart showcased the first computer mouse in 1968, made of wood.',
      year: '1968',
    ),
    WikiHistoryEvent(
      title: 'World Wide Web',
      fact: 'Tim Berners-Lee wrote the first web server and browser in 1990.',
      year: '1990',
    ),
  ];
  final day = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
  return fallbacks[day % fallbacks.length];
});
