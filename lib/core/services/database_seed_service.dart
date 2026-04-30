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

    final initialBadges = [
      {
        'id': 'the_initiate',
        'title': 'The Initiate',
        'description': 'Awarded for completing the first quest or tutorial.',
        'icon': 'stars_rounded',
      },
      {
        'id': 'seven_day_flame',
        'title': '7-Day Flame',
        'description': 'Maintaining a login or task streak for one full week.',
        'icon': 'local_fire_department_rounded',
      },
      {
        'id': 'critical_thinker',
        'title': 'Critical Thinker',
        'description': 'Scoring 100% on a high-difficulty quiz or challenge.',
        'icon': 'psychology_rounded',
      },
      {
        'id': 'syntax_sentinel',
        'title': 'Syntax Sentinel',
        'description': 'Complete 5 tasks without a syntax error.',
        'icon': 'verified_user_rounded',
      },
      {
        'id': 'knowledge_seeker',
        'title': 'Knowledge Seeker',
        'description':
            'Use the Search Bar to find and complete a specific topic.',
        'icon': 'search_rounded',
      },
      {
        'id': 'web_pioneer',
        'title': 'Web Pioneer',
        'description': 'Finish the featured article about the World Wide Web.',
        'icon': 'language_rounded',
      },
      {
        'id': 'the_chronologist',
        'title': 'The Chronologist',
        'description':
            'Read at least 5 articles in the "Notable Individuals" section.',
        'icon': 'history_rounded',
      },
      {
        'id': 'the_ethicist',
        'title': 'The Ethicist',
        'description':
            'Complete the "AI Ethics" module with a perfect quiz score.',
        'icon': 'gavel_rounded',
      },
      {
        'id': 'apprentice_archivist',
        'title': 'Apprentice Archivist',
        'description': 'Achieve your first perfect score.',
        'icon': 'inventory_2_rounded',
      },
      {
        'id': 'syntax_scholar_1',
        'title': 'Syntax Scholar I',
        'description': 'Perfect 3 Programming Languages in easy difficulty.',
        'icon': 'school_rounded',
      },
      {
        'id': 'syntax_scholar_2',
        'title': 'Syntax Scholar II',
        'description': 'Perfect 3 Programming Languages in medium difficulty.',
        'icon': 'school_rounded',
      },
      {
        'id': 'syntax_scholar_3',
        'title': 'Syntax Scholar III',
        'description': 'Perfect 3 Programming Languages in hard difficulty.',
        'icon': 'school_rounded',
      },
      {
        'id': 'algorithm_historian_1',
        'title': 'Algorithm Historian I',
        'description': 'Perfect 3 Algorithm problems in easy difficulty.',
        'icon': 'menu_book_rounded',
      },
      {
        'id': 'algorithm_historian_2',
        'title': 'Algorithm Historian II',
        'description': 'Perfect 3 Algorithm problems in medium difficulty.',
        'icon': 'menu_book_rounded',
      },
      {
        'id': 'algorithm_historian_3',
        'title': 'Algorithm Historian III',
        'description': 'Perfect 3 Algorithm problems in hard difficulty.',
        'icon': 'menu_book_rounded',
      },
      {
        'id': 'algorithm_ace',
        'title': 'Algorithm Ace',
        'description': 'Solve 10 algorithm challenges.',
        'icon': 'functions_rounded',
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
    ];

    for (var badge in initialBadges) {
      await badgesRef
          .doc(badge['id'] as String)
          .set(badge, SetOptions(merge: true));
    }
    debugPrint('Successfully seeded/updated ${initialBadges.length} badges.');
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
        estimatedMinutes: 10,
      ),
      QuestModel(
        id: 'q2',
        title: 'Debug the Void',
        description: 'Solve a logic challenge',
        xpReward: 120,
        difficulty: QuestDifficulty.medium,
        category: 'CODING',
        estimatedMinutes: 25,
      ),
      QuestModel(
        id: 'q3',
        title: 'Logic Gates',
        description: 'Score 100% on basics',
        xpReward: 80,
        difficulty: QuestDifficulty.easy,
        category: 'CS BASICS',
        estimatedMinutes: 15,
      ),
      QuestModel(
        id: 'q4',
        title: 'Complexity Analysis',
        description: 'Analyze 5 code snippets',
        xpReward: 200,
        difficulty: QuestDifficulty.hard,
        category: 'ALGORITHMS',
        estimatedMinutes: 40,
      ),
      QuestModel(
        id: 'q5',
        title: 'Shell Master',
        description: 'Perform 10 CLI operations',
        xpReward: 100,
        difficulty: QuestDifficulty.medium,
        category: 'TOOLS',
        estimatedMinutes: 20,
      ),
      QuestModel(
        id: 'q6',
        title: 'Quick Sort Challenge',
        description: 'Trace the partition logic',
        xpReward: 150,
        difficulty: QuestDifficulty.medium,
        category: 'ALGORITHMS',
        estimatedMinutes: 30,
      ),
    ];

    for (var quest in initialQuests) {
      await questsRef.doc(quest.id).set(quest.toMap());
    }
    debugPrint('Successfully seeded ${initialQuests.length} quests.');
  }
}
