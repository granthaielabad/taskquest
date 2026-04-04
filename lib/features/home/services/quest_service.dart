import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskquest/features/home/providers/quest_provider.dart';

class QuestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<QuestModel>> getDailyQuests() {
    // For a real app, you might filter by date or user
    return _db.collection('quests').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => QuestModel.fromMap(doc.data())).toList();
    });
  }

  Future<void> completeQuest(String userId, QuestModel quest) async {
    final batch = _db.batch();
    
    // 1. Mark quest as completed for this user (in a subcollection)
    final userQuestRef = _db.collection('users').doc(userId).collection('completedQuests').doc(quest.id);
    batch.set(userQuestRef, {
      'completedAt': FieldValue.serverTimestamp(),
      'xpEarned': quest.xpReward,
    });

    // 2. Update user's total XP and potentially Level
    final userRef = _db.collection('users').doc(userId);
    batch.update(userRef, {
      'xp': FieldValue.increment(quest.xpReward),
    });

    await batch.commit();
  }
}
