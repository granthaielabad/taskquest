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
        'description': 'Use the Search Bar to find and complete a specific topic.',
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
        'description': 'Read at least 5 articles in the "Notable Individuals" section.',
        'icon': 'history_rounded',
      },
      {
        'id': 'the_ethicist',
        'title': 'The Ethicist',
        'description': 'Complete the "AI Ethics" module with a perfect quiz score.',
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
      await badgesRef.doc(badge['id'] as String).set(badge, SetOptions(merge: true));
    }
    debugPrint('Successfully seeded/updated ${initialBadges.length} badges.');
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
        category: 'CODING',
      ),
      QuestModel(
        id: 'q3',
        title: 'Language Expert',
        description: 'Get a perfect score in "Which Lang?"',
        xpReward: 120,
        difficulty: QuestDifficulty.medium,
        category: 'QUIZ',
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
        category: 'CODING',
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
        description: 'Play "Which Lang?" 3 times today',
        xpReward: 110,
        difficulty: QuestDifficulty.medium,
        category: 'QUIZ',
      ),
      QuestModel(
        id: 'q11',
        title: 'Code Architect',
        description: 'Complete a Hard Code challenge',
        xpReward: 200,
        difficulty: QuestDifficulty.hard,
        category: 'CODING',
      ),
      QuestModel(
        id: 'q12',
        title: 'Architecture Ace',
        description: 'Complete an SDLC sequence',
        xpReward: 140,
        difficulty: QuestDifficulty.medium,
        category: 'ARCHITECTURE',
      ),
      QuestModel(
        id: 'q13',
        title: 'Binary Brain',
        description: 'Solve an advanced algorithm trace',
        xpReward: 180,
        difficulty: QuestDifficulty.hard,
        category: 'CS BASICS',
      ),
      QuestModel(
        id: 'q14',
        title: 'Memory Master',
        description: 'Review 50 flashcards today',
        xpReward: 120,
        difficulty: QuestDifficulty.medium,
        category: 'STUDY',
      ),
      QuestModel(
        id: 'q15',
        title: 'Social Butterfly',
        description: 'Engage with the community leaderboard',
        xpReward: 50,
        difficulty: QuestDifficulty.easy,
        category: 'SOCIAL',
      ),
      QuestModel(
        id: 'q16',
        title: 'Neural Network',
        description: 'Use the AI Scan feature',
        xpReward: 100,
        difficulty: QuestDifficulty.medium,
        category: 'AI',
      ),
      QuestModel(
        id: 'q17',
        title: 'Logic Legend',
        description: 'Complete 3 logic challenges',
        xpReward: 160,
        difficulty: QuestDifficulty.hard,
        category: 'LOGIC',
      ),
    ];

    for (var quest in initialQuests) {
      await questsRef.doc(quest.id).set(quest.toMap());
    }
    debugPrint('Successfully seeded ${initialQuests.length} new quests.');
  }
}
