import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:taskquest/features/home/providers/quest_provider.dart';

class DatabaseSeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedAll() async {
    await seedBadges();
    await seedQuests();
  }

  Future<void> seedBadges() async {
    final badgesRef = _db.collection('badges');
    final snapshot = await badgesRef.get();

    if (snapshot.docs.isNotEmpty) {
      debugPrint('Badges already seeded.');
      return;
    }

    final initialBadges = [
      {
        'id': 'first_flight',
        'title': 'First Flight',
        'description': 'Complete your first quest',
        'icon': 'auto_awesome_rounded',
      },
      {
        'id': 'syntax_sage',
        'title': 'Syntax Sage',
        'description': 'Review 50+ flashcards',
        'icon': 'history_edu_rounded',
      },
      {
        'id': 'bug_hunter',
        'title': 'Bug Hunter',
        'description': 'Solve 10 code block challenges',
        'icon': 'bug_report_rounded',
      },
      {
        'id': 'logic_master',
        'title': 'Logic Master',
        'description': 'Get 100% on a logic quiz',
        'icon': 'psychology_rounded',
      },
      {
        'id': 'polyglot',
        'title': 'Polyglot',
        'description': 'Identify 5 different languages',
        'icon': 'language_rounded',
      },
      {
        'id': 'flash_ai',
        'title': 'Flash AI',
        'description': 'Generate 5 AI flashcard decks',
        'icon': 'bolt_rounded',
      },
    ];

    for (var badge in initialBadges) {
      await badgesRef.doc(badge['id'] as String).set(badge);
    }
    debugPrint('Successfully seeded ${initialBadges.length} badges.');
  }

  Future<void> seedQuests() async {
    final questsRef = _db.collection('quests');
    final snapshot = await questsRef.get();

    if (snapshot.docs.isNotEmpty) {
      debugPrint('Quests already seeded.');
      return;
    }

    final initialQuests = [
      QuestModel(
        id: 'q1',
        title: 'Flashcard Review',
        description: 'Complete one study session',
        xpReward: 50,
        difficulty: QuestDifficulty.easy,
        category: 'ALGORITHMS',
      ),
      QuestModel(
        id: 'q2',
        title: 'Debug the Void',
        description: 'Solve a logic challenge',
        xpReward: 120,
        difficulty: QuestDifficulty.medium,
        category: 'CODING',
      ),
      QuestModel(
        id: 'q3',
        title: 'Logic Gates',
        description: 'Score 100% on basics',
        xpReward: 80,
        difficulty: QuestDifficulty.easy,
        category: 'CS BASICS',
      ),
    ];

    for (var quest in initialQuests) {
      await questsRef.doc(quest.id).set(quest.toMap());
    }
    debugPrint('Successfully seeded ${initialQuests.length} quests.');
  }
}
