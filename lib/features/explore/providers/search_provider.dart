import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/home/providers/quest_provider.dart';

class SearchResult {
  final String title;
  final String category;
  final String type; // 'QUEST', 'CONCEPT', 'ARTICLE'
  final dynamic originalData;

  SearchResult({
    required this.title,
    required this.category,
    required this.type,
    this.originalData,
  });
}

final searchResultsProvider = Provider.family<List<SearchResult>, String>((
  ref,
  query,
) {
  if (query.isEmpty) return [];

  final List<SearchResult> allResults = [];

  // 1. Search through Quests
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

  // 2. Mock some "Learning Concepts" for now to make explorer feel alive
  final mockConcepts = [
    {
      'title': 'Data Structures 101',
      'cat': 'COMPUTER SCIENCE',
      'type': 'CONCEPT',
    },
    {'title': 'Big O Notation Guide', 'cat': 'ALGORITHMS', 'type': 'CONCEPT'},
    {'title': 'Binary Search Tree PDF', 'cat': 'ALGORITHMS', 'type': 'ARTICLE'},
    {'title': 'Recursion Explained', 'cat': 'PROGRAMMING', 'type': 'CONCEPT'},
    {'title': 'SQL vs NoSQL', 'cat': 'DATABASES', 'type': 'ARTICLE'},
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

  return allResults;
});
