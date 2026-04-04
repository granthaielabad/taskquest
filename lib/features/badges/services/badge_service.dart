import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskquest/features/badges/providers/badge_provider.dart';

class BadgeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<BadgeModel>> getUserBadges(String userId) async {
    // 1. Get all possible badges
    final allBadgesSnapshot = await _db.collection('badges').get();
    
    // 2. Get user's unlocked badges list
    final userDoc = await _db.collection('users').doc(userId).get();
    final unlockedIds = List<String>.from(userDoc.data()?['unlockedBadges'] ?? []);

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

  Future<void> checkSyntaxSage(String userId, int cardsReviewed) async {
    final statsRef = _db.collection('users').doc(userId).collection('stats').doc('flashcards');
    await statsRef.set({
      'totalReviewed': FieldValue.increment(cardsReviewed),
    }, SetOptions(merge: true));

    final doc = await statsRef.get();
    if ((doc.data()?['totalReviewed'] ?? 0) >= 50) {
      await unlockBadge(userId, 'syntax_sage');
    }
  }

  Future<void> checkBugHunter(String userId) async {
    final statsRef = _db.collection('users').doc(userId).collection('stats').doc('coding');
    await statsRef.set({
      'challengesSolved': FieldValue.increment(1),
    }, SetOptions(merge: true));

    final doc = await statsRef.get();
    if ((doc.data()?['challengesSolved'] ?? 0) >= 10) {
      await unlockBadge(userId, 'bug_hunter');
    }
  }

  Future<void> checkFlashAI(String userId) async {
    final statsRef = _db.collection('users').doc(userId).collection('stats').doc('ai');
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
