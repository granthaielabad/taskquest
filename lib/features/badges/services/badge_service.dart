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
}
