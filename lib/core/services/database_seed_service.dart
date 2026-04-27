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

    // If quests already exist, we clear them to ensure the new list is applied
    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }

    final initialQuests = [
      QuestModel(
        id: 'q1',
        title: 'Logic Gates',
        description: 'Score 100% on CS basics',
        xpReward: 80,
        difficulty: QuestDifficulty.easy,
        category: 'CS BASICS',
      ),
      QuestModel(
        id: 'q2',
        title: 'Code Sprint',
        description: 'Complete a Code Blocks game',
        xpReward: 150,
        difficulty: QuestDifficulty.medium,
        category: 'GAMES',
      ),
      QuestModel(
        id: 'q3',
        title: 'Language Expert',
        description: 'Get a perfect score in "Which Lang?"',
        xpReward: 120,
        difficulty: QuestDifficulty.medium,
        category: 'GAMES',
      ),
      QuestModel(
        id: 'q4',
        title: 'Flash Focus',
        description: 'Review 20 flashcards in one go',
        xpReward: 60,
        difficulty: QuestDifficulty.easy,
        category: 'STUDY',
      ),
      QuestModel(
        id: 'q5',
        title: 'AI Genesis',
        description: 'Generate an AI study deck',
        xpReward: 70,
        difficulty: QuestDifficulty.easy,
        category: 'AI',
      ),
      QuestModel(
        id: 'q6',
        title: 'Bug Hunter',
        description: 'Find the error in a Code Blocks challenge',
        xpReward: 130,
        difficulty: QuestDifficulty.medium,
        category: 'GAMES',
      ),
      QuestModel(
        id: 'q7',
        title: 'Syntax Mastery',
        description: 'Finish 3 study sessions today',
        xpReward: 90,
        difficulty: QuestDifficulty.easy,
        category: 'STUDY',
      ),
      QuestModel(
        id: 'q8',
        title: 'Global Scholar',
        description: 'Check your rank on the leaderboard',
        xpReward: 30,
        difficulty: QuestDifficulty.easy,
        category: 'SOCIAL',
      ),
      QuestModel(
        id: 'q9',
        title: 'Deep Explorer',
        description: 'Browse 5 topics in the Explore tab',
        xpReward: 40,
        difficulty: QuestDifficulty.easy,
        category: 'EXPLORE',
      ),
      QuestModel(
        id: 'q10',
        title: 'Polyglot Trial',
        description: 'Play "Which Lang?" for 5 minutes',
        xpReward: 110,
        difficulty: QuestDifficulty.medium,
        category: 'GAMES',
      ),
      QuestModel(
        id: 'q11',
        title: 'Code Architect',
        description: 'Complete a Hard Code challenge',
        xpReward: 200,
        difficulty: QuestDifficulty.hard,
        category: 'GAMES',
      ),
      QuestModel(
        id: 'q12',
        title: 'Daily Ritual',
        description: 'Maintain your streak for 3 days',
        xpReward: 100,
        difficulty: QuestDifficulty.medium,
        category: 'STREAK',
      ),
    ];

    for (var quest in initialQuests) {
      await questsRef.doc(quest.id).set(quest.toMap());
    }
    debugPrint('Successfully seeded ${initialQuests.length} new quests.');
  }
}
