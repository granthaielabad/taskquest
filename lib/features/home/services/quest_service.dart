import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskquest/features/home/providers/quest_provider.dart';
import 'package:taskquest/core/utils/xp_utils.dart';
import 'package:rxdart/rxdart.dart';

class QuestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<QuestModel>> getDailyQuests(String userId) {
    final questsStream = _db.collection('quests').snapshots();
    final completedStream = _db
        .collection('users')
        .doc(userId)
        .collection('completedQuests')
        .snapshots();

    return Rx.combineLatest2(questsStream, completedStream,
        (QuerySnapshot questsSnap, QuerySnapshot completedSnap) {
      final completedIds = completedSnap.docs.map((doc) => doc.id).toSet();

      return questsSnap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return QuestModel.fromMap({
          ...data,
          'id': doc.id,
          'isCompleted': completedIds.contains(doc.id),
        });
      }).toList();
    });
  }

  Future<void> completeQuest(String userId, QuestModel quest) async {
    // 1. Get user to calculate new level
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) return;

    final currentXp = userDoc.data()?['xp'] ?? 0;
    final currentUnlockedBadges = List<String>.from(
      userDoc.data()?['unlockedBadges'] ?? [],
    );

    final newXp = currentXp + quest.xpReward;
    final newLevel = XpUtils.calculateLevel(newXp);

    final batch = _db.batch();

    // 2. Mark quest as completed
    final userQuestRef = _db
        .collection('users')
        .doc(userId)
        .collection('completedQuests')
        .doc(quest.id);
    batch.set(userQuestRef, {
      'completedAt': FieldValue.serverTimestamp(),
      'xpEarned': quest.xpReward,
    });

    // 3. Update user profile (XP + Level)
    final userRef = _db.collection('users').doc(userId);
    batch.update(userRef, {'xp': newXp, 'level': newLevel});

    // 4. Check for "First Flight" Badge
    if (!currentUnlockedBadges.contains('first_flight')) {
      batch.update(userRef, {
        'unlockedBadges': FieldValue.arrayUnion(['first_flight']),
      });
    }

    await batch.commit();
  }
}
