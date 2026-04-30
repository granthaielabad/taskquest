// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';

enum ActivityType { quest, scan, game, study }

class ActivityModel {
  final String id;
  final String title;
  final String subtitle;
  final int xpReward;
  final DateTime timestamp;
  final ActivityType type;

  ActivityModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.xpReward,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'xpReward': xpReward,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.name,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      xpReward: map['xpReward'] ?? 0,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      type: ActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ActivityType.quest,
      ),
    );
  }
}

class ActivityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ActivityModel>> getActivities(String userId, {int limit = 10}) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ActivityModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> recordActivity(String userId, ActivityModel activity) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc(activity.id)
        .set(activity.toMap());
  }
}

final activityServiceProvider = Provider<ActivityService>((ref) {
  return ActivityService();
});

final recentActivitiesProvider = StreamProvider<List<ActivityModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(activityServiceProvider).getActivities(user.uid, limit: 5);
});

final allActivitiesProvider = StreamProvider<List<ActivityModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(activityServiceProvider).getActivities(user.uid, limit: 50);
});
