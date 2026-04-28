import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskquest/features/home/providers/quest_provider.dart';
import 'package:taskquest/core/utils/xp_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:taskquest/features/settings/services/notification_service.dart';

class QuestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<QuestModel>> getDailyQuests(String userId, {int? seed}) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final effectiveSeed = seed ?? (now.year * 10000 + now.month * 100 + now.day);

    final questsStream = _db.collection('quests').snapshots();
    final completedStream = _db
        .collection('users')
        .doc(userId)
        .collection('completedQuests')
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .snapshots();

    return Rx.combineLatest2<QuerySnapshot, QuerySnapshot, List<QuestModel>>(
      questsStream,
      completedStream,
      (questsSnap, completedSnap) {
        final completedIds = completedSnap.docs.map((doc) => doc.id).toSet();
        final random = Random(effectiveSeed);

        List<QuestModel> allQuests = questsSnap.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return QuestModel.fromMap({
            ...data,
            'id': doc.id,
            'isCompleted': completedIds.contains(doc.id),
          });
        }).toList();

        if (allQuests.isEmpty) return [];

        allQuests.shuffle(random);
        return allQuests.take(3).toList();
      },
    );
  }

  Future<void> completeQuestsByType(String userId, String category) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final seed = now.year * 10000 + now.month * 100 + now.day;
      
      final questsSnap = await _db.collection('quests').get();
      final completedSnap = await _db.collection('users').doc(userId).collection('completedQuests')
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();
          
      final completedIds = completedSnap.docs.map((doc) => doc.id).toSet();
      final random = Random(seed);

      List<QuestModel> allQuests = questsSnap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return QuestModel.fromMap({...data, 'id': doc.id, 'isCompleted': completedIds.contains(doc.id)});
      }).toList();
      
      allQuests.shuffle(random);
      final dailyQuests = allQuests.take(3).toList();

      for (final quest in dailyQuests) {
        if (quest.category.toUpperCase() == category.toUpperCase() && !quest.isCompleted) {
          await completeQuest(userId, quest);
          // High-priority notification for daily challenge completion
          NotificationService().showNotification(
            id: 200 + quest.id.hashCode,
            title: 'Daily Challenge Done! 🏆',
            body: '${quest.title}: +${quest.xpReward} XP',
          );
        }
      }
    } catch (e) {
      debugPrint('Error auto-completing quests: $e');
    }
  }

  Future<void> completeQuest(String userId, QuestModel quest) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final currentXp = userDoc.data()?['xp'] ?? 0;
      final currentUnlockedBadges = List<String>.from(
        userDoc.data()?['unlockedBadges'] ?? [],
      );

      final newXp = currentXp + quest.xpReward;
      final newLevel = XpUtils.calculateLevel(newXp);

      final batch = _db.batch();

      final userQuestRef = _db
          .collection('users')
          .doc(userId)
          .collection('completedQuests')
          .doc(quest.id);

      batch.set(userQuestRef, {
        'completedAt': FieldValue.serverTimestamp(),
        'xpEarned': quest.xpReward,
      });

      final userRef = _db.collection('users').doc(userId);
      batch.update(userRef, {'xp': newXp, 'level': newLevel});

      if (!currentUnlockedBadges.contains('first_flight')) {
        batch.update(userRef, {
          'unlockedBadges': FieldValue.arrayUnion(['first_flight']),
        });
      }

      await batch.commit();
      debugPrint('QuestService: Daily Quest ${quest.title} committed.');
    } catch (e) {
      debugPrint('Error completing quest: $e');
    }
  }
}
