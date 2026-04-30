import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskquest/features/home/providers/quest_provider.dart';
import 'package:taskquest/core/utils/xp_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:taskquest/features/settings/services/notification_service.dart';
import 'package:taskquest/features/home/providers/activity_provider.dart';

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

        allQuests.sort((a, b) => a.id.compareTo(b.id));
        allQuests.shuffle(random);
        return allQuests.take(3).toList();
      },
    );
  }

  Future<void> completeQuestsByType(String userId, String category, {double accuracy = 0.0, String? difficulty}) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final seed = now.year * 10000 + now.month * 100 + now.day;
      
      final questsSnap = await _db.collection('quests').get();
      final completedSnap = await _db.collection('users').doc(userId).collection('completedQuests')
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();
          
      final activitiesSnap = await _db.collection('users').doc(userId).collection('activities')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      final activities = activitiesSnap.docs.map((doc) => ActivityModel.fromMap(doc.data())).toList();
      final completedIds = completedSnap.docs.map((doc) => doc.id).toSet();
      final random = Random(seed);

      List<QuestModel> allQuests = questsSnap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return QuestModel.fromMap({...data, 'id': doc.id, 'isCompleted': completedIds.contains(doc.id)});
      }).toList();
      
      allQuests.sort((a, b) => a.id.compareTo(b.id));
      allQuests.shuffle(random);
      final dailyQuests = allQuests.take(3).toList();

      final targetCat = category.trim().toUpperCase();

      for (final quest in dailyQuests) {
        if (quest.category.trim().toUpperCase() == targetCat && !quest.isCompleted) {
          bool meetsRequirement = true;
          final descLower = quest.description.toLowerCase();
          final titleLower = quest.title.toLowerCase();
          
          // 1. Accuracy Check
          if (descLower.contains('100%') || descLower.contains('perfect')) {
            meetsRequirement = accuracy >= 1.0;
          }

          // 2. Difficulty Check (Strictly require HARD for specific quests)
          if (quest.id == 'q11' || quest.id == 'q14' || 
              descLower.contains('hard challenge') || 
              descLower.contains('advanced algorithm')) {
             meetsRequirement = meetsRequirement && (difficulty?.toUpperCase() == 'HARD');
          }

          // 3. Accumulation Check: Memory Master
          if (quest.id == 'q15' || titleLower.contains('memory master')) {
            int totalReviewed = 0;
            for (var act in activities) {
              if (act.type == ActivityType.study && act.subtitle.contains('Reviewed')) {
                final match = RegExp(r'Reviewed (\d+) cards').firstMatch(act.subtitle);
                if (match != null) {
                  totalReviewed += int.parse(match.group(1)!);
                }
              }
            }
            meetsRequirement = totalReviewed >= 50;
          }

          // 4. Accumulation Check: Polyglot Trial
          if (quest.id == 'q10' || titleLower.contains('polyglot trial')) {
            int playCount = 0;
            for (var act in activities) {
              if (act.type == ActivityType.game && act.title.contains('Which Lang?')) {
                playCount++;
              }
            }
            meetsRequirement = playCount >= 3;
          }

          if (meetsRequirement) {
            await completeQuest(userId, quest);
            
            final title = 'Daily Challenge Done! 🏆';
            final body = '${quest.title}: +${quest.xpReward} XP';
            
            NotificationService().showNotification(
              id: 200 + quest.id.hashCode,
              title: title,
              body: body,
            );

            await _db.collection('users').doc(userId).collection('notifications').add({
              'title': title,
              'body': body,
              'timestamp': FieldValue.serverTimestamp(),
              'type': 'quest',
            });
          }
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
      final levelData = XpUtils.getLevelProgress(newXp);
      final newLevel = levelData['level'] as int;

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
