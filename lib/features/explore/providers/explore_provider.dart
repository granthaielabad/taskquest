// Copyright (c) 2026 TaskQuest. All rights reserved.

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
    bool clearContinueToken = false,
    String? category,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return PioneersState(
      pioneers: pioneers ?? this.pioneers,
      continueToken: clearContinueToken
          ? null
          : (continueToken ?? this.continueToken),
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class PioneersNotifier extends AsyncNotifier<PioneersState> {
  Timer? _debounce;

  @override
  FutureOr<PioneersState> build() async {
    final response = await ref
        .read(exploreApiServiceProvider)
        .fetchPioneersPaginated();

    ref.onDispose(() {
      _debounce?.cancel();
    });

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
        currentState.isLoadingMore ||
        currentState.searchQuery.isNotEmpty) {
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
          clearContinueToken: response.continueToken == null,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setCategory(String category) async {
    _debounce?.cancel();
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
    if (currentState == null) return;

    state = AsyncData(currentState.copyWith(searchQuery: query));

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        await setCategory(currentState.category);
        return;
      }

      state = const AsyncLoading();
      try {
        final results = await ref
            .read(exploreApiServiceProvider)
            .searchPioneers(query);

        state = AsyncData(
          PioneersState(
            pioneers: results,
            continueToken: null,
            category: currentState.category,
            searchQuery: query,
          ),
        );
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    });
  }
}

final pioneersProvider = AsyncNotifierProvider<PioneersNotifier, PioneersState>(
  () {
    return PioneersNotifier();
  },
);

final computingTimelineProvider = FutureProvider<List<WikiTimelineItem>>((
  ref,
) async {
  try {
    final items = await ref
        .watch(exploreApiServiceProvider)
        .fetchComputingTimeline();
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
    WikiHistoryEvent(
      title: 'Linux Kernel',
      fact:
          'Linus Torvalds posted his famous message about a "hobby" OS in 1991.',
      year: '1991',
    ),
    WikiHistoryEvent(
      title: 'Python Released',
      fact:
          'Guido van Rossum released the first version of Python in February 1991.',
      year: '1991',
    ),
    WikiHistoryEvent(
      title: 'Apple I Computer',
      fact: 'The Apple I was released in 1976, designed by Steve Wozniak.',
      year: '1976',
    ),
    WikiHistoryEvent(
      title: 'First Email Sent',
      fact:
          'Ray Tomlinson sent the first network email in 1971, using the @ symbol.',
      year: '1971',
    ),
    WikiHistoryEvent(
      title: 'Game Boy Launch',
      fact:
          'Nintendo released the Game Boy in 1989, revolutionizing mobile gaming.',
      year: '1989',
    ),
    WikiHistoryEvent(
      title: 'COBOL Created',
      fact:
          'Grace Hopper and her team developed COBOL, a pioneering business language.',
      year: '1959',
    ),
    WikiHistoryEvent(
      title: 'Bitcoin Genesis',
      fact:
          'Satoshi Nakamoto mined the first block of Bitcoin in January 2009.',
      year: '2009',
    ),
  ];
  final day = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
  return fallbacks[day % fallbacks.length];
});

final crashCoursesProvider = FutureProvider<List<TutorialCourse>>((ref) async {
  return ref.watch(exploreApiServiceProvider).fetchCrashCourses();
});
