// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/utils/algorithms.dart';
import 'package:taskquest/features/home/providers/quest_provider.dart';
import 'package:taskquest/features/explore/providers/explore_provider.dart';
import 'package:taskquest/features/explore/services/explore_api_service.dart';

class SearchResult {
  final String title;
  final String category;
  final String type; // 'QUEST', 'CONCEPT', 'ARTICLE', 'WIKI'
  final String? url;
  final dynamic originalData;
  bool isExactMatch; // New field for algorithm demonstration

  SearchResult({
    required this.title,
    required this.category,
    required this.type,
    this.url,
    this.originalData,
    this.isExactMatch = false,
  });
}

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

final exploreSearchProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final List<SearchResult> allResults = [];

  // 1. Search through local Quests
  final quests = ref.watch(dailyQuestsProvider).value ?? [];
  for (var quest in quests) {
    if (quest.title.toLowerCase().contains(query.toLowerCase()) ||
        quest.description.toLowerCase().contains(query.toLowerCase())) {
      allResults.add(
        SearchResult(
          title: quest.title,
          category: quest.category,
          type: 'QUEST',
          originalData: quest,
        ),
      );
    }
  }

  // 2. Concurrently search through Dev.to and Wikipedia
  try {
    final results = await Future.wait([
      ref.read(exploreApiServiceProvider).searchArticles(query),
      ref.read(exploreApiServiceProvider).searchWikipedia(query),
    ]);

    final apiArticles = results[0] as List<ExploreArticle>;
    final wikiResults = results[1] as List<WikiSearchResult>;

    for (var article in apiArticles) {
      allResults.add(
        SearchResult(
          title: article.title,
          category: article.tags.isNotEmpty
              ? article.tags.first.toUpperCase()
              : 'TECH',
          type: 'ARTICLE',
          url: article.url,
          originalData: article,
        ),
      );
    }

    for (var wiki in wikiResults) {
      allResults.add(
        SearchResult(
          title: wiki.title,
          category: 'HISTORY',
          type: 'WIKI',
          url: wiki.title, // Use title as ID for fetching summary
        ),
      );
    }
  } catch (e) {
    // Ignore API search errors
  }

  // 3. Mock some "Learning Concepts"
  final mockConcepts = [
    {
      'title': 'Data Structures 101',
      'cat': 'COMPUTER SCIENCE',
      'type': 'CONCEPT',
    },
    {'title': 'Big O Notation Guide', 'cat': 'ALGORITHMS', 'type': 'CONCEPT'},
    {'title': 'Recursion Explained', 'cat': 'PROGRAMMING', 'type': 'CONCEPT'},
    {'title': 'Solid Principles', 'cat': 'ARCHITECTURE', 'type': 'CONCEPT'},
  ];

  for (var concept in mockConcepts) {
    if (concept['title']!.toLowerCase().contains(query.toLowerCase())) {
      allResults.add(
        SearchResult(
          title: concept['title']!,
          category: concept['cat']!,
          type: concept['type']!,
        ),
      );
    }
  }

  // 4. Applying Core Algorithms
  if (allResults.isNotEmpty) {
    // Application of Algorithm 1: QUICK SORT (O(N log N))
    // We sort the results by title alphabetically to prepare for Binary Search
    TaskQuestAlgorithms.quickSort<SearchResult>(
      allResults,
      0,
      allResults.length - 1,
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );

    // Application of Algorithm 2: BINARY SEARCH (O(log N))
    // We look for an exact title match for the query
    final target = SearchResult(title: query, category: '', type: '');
    final matchIndex = TaskQuestAlgorithms.binarySearch<SearchResult>(
      allResults,
      target,
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );

    if (matchIndex != -1) {
      allResults[matchIndex].isExactMatch = true;
      // Move exact match to front
      final match = allResults.removeAt(matchIndex);
      allResults.insert(0, match);
    }
  }

  return allResults;
});
