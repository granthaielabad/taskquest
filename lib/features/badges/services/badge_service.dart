// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskquest/features/badges/providers/badge_provider.dart';
import 'package:taskquest/features/games/models/game_models.dart';

class BadgeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<BadgeModel>> getUserBadges(String userId) async {
    // 1. Get all possible badges
    final allBadgesSnapshot = await _db.collection('badges').get();

    // 2. Get user's unlocked badges list
    final userDoc = await _db.collection('users').doc(userId).get();
    final unlockedIds = List<String>.from(
      userDoc.data()?['unlockedBadges'] ?? [],
    );

    return allBadgesSnapshot.docs.map((doc) {
      final isUnlocked = unlockedIds.contains(doc.id);
      return BadgeModel.fromMap(doc.data(), isUnlocked, null);
    }).toList();
  }

  Future<void> unlockBadge(String userId, String badgeId) async {
    await _db.collection('users').doc(userId).update({
      'unlockedBadges': FieldValue.arrayUnion([badgeId]),
    });
  }

  /// ── Progress Checks ─────────────────────────────────────────

  Future<void> checkInitiate(String userId) async {
    await unlockBadge(userId, 'the_initiate');
  }

  Future<void> checkStreak(String userId, int streak) async {
    if (streak >= 7) {
      await unlockBadge(userId, 'seven_day_flame');
    }
  }

  Future<void> checkPerfectScore(
    String userId,
    GameType type,
    String difficulty,
  ) async {
    final statsRef = _db
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('games');

    // Increment total perfect scores for Apprentice Archivist
    await statsRef.set({
      'totalPerfectScores': FieldValue.increment(1),
    }, SetOptions(merge: true));

    final doc = await statsRef.get();
    if ((doc.data()?['totalPerfectScores'] ?? 0) == 1) {
      await unlockBadge(userId, 'apprentice_archivist');
    }

    if (type == GameType.quiz) {
      if (difficulty == 'hard') {
        await unlockBadge(userId, 'critical_thinker');
      }

      String field;
      String badgeId;
      if (difficulty == 'easy') {
        field = 'quizPerfectEasy';
        badgeId = 'syntax_scholar_1';
      } else if (difficulty == 'medium') {
        field = 'quizPerfectMedium';
        badgeId = 'syntax_scholar_2';
      } else {
        field = 'quizPerfectHard';
        badgeId = 'syntax_scholar_3';
      }

      await statsRef.set({
        field: FieldValue.increment(1),
      }, SetOptions(merge: true));

      final updatedDoc = await statsRef.get();
      if ((updatedDoc.data()?[field] ?? 0) >= 3) {
        await unlockBadge(userId, badgeId);
      }
    } else if (type == GameType.algorithm) {
      String field;
      String badgeId;
      if (difficulty == 'easy') {
        field = 'algoPerfectEasy';
        badgeId = 'algorithm_historian_1';
      } else if (difficulty == 'medium') {
        field = 'algoPerfectMedium';
        badgeId = 'algorithm_historian_2';
      } else {
        field = 'algoPerfectHard';
        badgeId = 'algorithm_historian_3';
      }

      await statsRef.set({
        field: FieldValue.increment(1),
      }, SetOptions(merge: true));

      final updatedDoc = await statsRef.get();
      if ((updatedDoc.data()?[field] ?? 0) >= 3) {
        await unlockBadge(userId, badgeId);
      }
    }
  }

  Future<void> checkArticleRead(
    String userId,
    String articleId,
    String category,
  ) async {
    if (articleId == 'web_history_featured') {
      await unlockBadge(userId, 'web_pioneer');
    }

    if (category == 'Notable Individuals') {
      final statsRef = _db
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('articles');
      await statsRef.set({
        'notableIndividualsReadCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      final doc = await statsRef.get();
      if ((doc.data()?['notableIndividualsReadCount'] ?? 0) >= 5) {
        await unlockBadge(userId, 'the_chronologist');
      }
    }
  }

  Future<void> checkAlgorithmAce(String userId) async {
    final statsRef = _db
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('algorithm');
    await statsRef.set({
      'algorithmAceCount': FieldValue.increment(1),
    }, SetOptions(merge: true));

    final doc = await statsRef.get();
    if ((doc.data()?['algorithmAceCount'] ?? 0) >= 10) {
      await unlockBadge(userId, 'algorithm_ace');
    }
  }

  Future<void> checkSearchBadge(String userId) async {
    await unlockBadge(userId, 'knowledge_seeker');
  }

  Future<void> checkSyntaxSentinel(String userId) async {
    final statsRef = _db
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('learning');
    await statsRef.set({
      'tasksWithoutSyntaxError': FieldValue.increment(1),
    }, SetOptions(merge: true));

    final doc = await statsRef.get();
    if ((doc.data()?['tasksWithoutSyntaxError'] ?? 0) >= 5) {
      await unlockBadge(userId, 'syntax_sentinel');
    }
  }

  Future<void> checkEthicist(
    String userId,
    String module,
    bool isPerfect,
  ) async {
    if (module == 'AI Ethics' && isPerfect) {
      await unlockBadge(userId, 'the_ethicist');
    }
  }

  Future<void> checkSyntaxSage(String userId, int cardsReviewed) async {
    final statsRef = _db
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('flashcards');
    await statsRef.set({
      'totalReviewed': FieldValue.increment(cardsReviewed),
    }, SetOptions(merge: true));

    final doc = await statsRef.get();
    if ((doc.data()?['totalReviewed'] ?? 0) >= 50) {
      await unlockBadge(userId, 'syntax_sage');
    }
  }

  Future<void> checkBugHunter(String userId) async {
    final statsRef = _db
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('coding');
    await statsRef.set({
      'challengesSolved': FieldValue.increment(1),
    }, SetOptions(merge: true));

    final doc = await statsRef.get();
    if ((doc.data()?['challengesSolved'] ?? 0) >= 10) {
      await unlockBadge(userId, 'bug_hunter');
    }
  }

  Future<void> checkFlashAI(String userId) async {
    final statsRef = _db
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('ai');
    await statsRef.set({
      'decksGenerated': FieldValue.increment(1),
    }, SetOptions(merge: true));

    final doc = await statsRef.get();
    if ((doc.data()?['decksGenerated'] ?? 0) >= 5) {
      await unlockBadge(userId, 'flash_ai');
    }
  }

  Future<void> checkLogicMaster(String userId, bool isPerfectScore) async {
    if (isPerfectScore) {
      await unlockBadge(userId, 'logic_master');
    }
  }
}
