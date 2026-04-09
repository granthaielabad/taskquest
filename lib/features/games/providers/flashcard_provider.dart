import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/games/services/flashcard_service.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';

class FlashcardModel {
  final String id;
  final String term;
  final String definition;

  FlashcardModel({
    required this.id,
    required this.term,
    required this.definition,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'term': term, 'definition': definition};
  }

  factory FlashcardModel.fromMap(Map<String, dynamic> map) {
    return FlashcardModel(
      id: map['id'] ?? '',
      term: map['term'] ?? '',
      definition: map['definition'] ?? '',
    );
  }
}

class FlashcardDeckModel {
  final String id;
  final String userId;
  final String title;
  final String type; // 'AI' or 'Manual'
  final String category; // e.g., 'Data Structures', 'Algorithms'
  final List<FlashcardModel> cards;
  final int masteryProgress; // 0-100
  final DateTime createdAt;

  FlashcardDeckModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    this.category = 'General',
    required this.cards,
    this.masteryProgress = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'type': type,
      'category': category,
      'cards': cards.map((c) => c.toMap()).toList(),
      'masteryProgress': masteryProgress,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory FlashcardDeckModel.fromMap(Map<String, dynamic> map) {
    return FlashcardDeckModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? 'Manual',
      category: map['category'] ?? 'General',
      cards: (map['cards'] as List? ?? [])
          .map((c) => FlashcardModel.fromMap(c as Map<String, dynamic>))
          .toList(),
      masteryProgress: map['masteryProgress'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

final flashcardServiceProvider = Provider<FlashcardService>((ref) {
  return FlashcardService();
});

final userDecksProvider = StreamProvider<List<FlashcardDeckModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(flashcardServiceProvider).getUserDecks(user.uid);
});
