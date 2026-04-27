import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/core/utils/xp_utils.dart';
import 'package:taskquest/features/settings/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
      debugPrint('UserService: Profile created successfully for ${user.uid}');
    } catch (e) {
      debugPrint('UserService ERROR: Failed to create profile: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('UserService ERROR: Failed to get profile: $e');
      return null;
    }
  }

  Future<void> updateXp(String uid, int newXp, int newLevel) async {
    await _db.collection('users').doc(uid).update({
      'xp': newXp,
      'level': newLevel,
    });
  }

  /// Adds a persistent notification record to Firestore
  Future<void> _savePersistentNotification(String uid, {
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      await _db.collection('users').doc(uid).collection('notifications').add({
        'title': title,
        'body': body,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }
  }

  Future<void> addXp(String uid, int xpToAdd) async {
    final user = await getUserProfile(uid);
    if (user == null) return;

    final oldLevel = user.level;
    final newTotalXp = user.xp + xpToAdd;
    final levelData = XpUtils.getLevelProgress(newTotalXp);
    final newLevel = levelData['level'] as int;
    final nextThreshold = levelData['nextLevelXpThreshold'] as int;

    await updateXp(uid, newTotalXp, newLevel);

    // ── GET NOTIFICATION SETTINGS ───────────────────────────────
    final prefs = await SharedPreferences.getInstance();
    final settings = prefs.getStringList('notification_settings_v5') ?? [];
    
    bool isAllOn = true;
    bool isXpOn = false;
    bool isQuestOn = true;

    for (var s in settings) {
      if (s == 'all:false') isAllOn = false;
      if (s == 'xp:true') isXpOn = true;
      if (s == 'quest:false') isQuestOn = false; 
    }

    // ── ALWAYS SAVE TO HOME NOTIFICATION SCREEN (PERSISTENT) ───
    if (newLevel > oldLevel) {
      const title = 'Level Up! 🎉';
      final body = 'Congratulations! You\'ve reached Level $newLevel.';
      if (isAllOn && isXpOn) NotificationService().showNotification(id: 7, title: title, body: body);
      await _savePersistentNotification(uid, title: title, body: body, type: 'level_up');
    } else if (nextThreshold - newTotalXp <= 50) {
      const title = 'Level Up Imminent! ⚡';
      final body = 'You are only ${nextThreshold - newTotalXp} XP away from Level ${newLevel + 1}!';
      if (isAllOn && isXpOn) NotificationService().showNotification(id: 4, title: title, body: body);
      await _savePersistentNotification(uid, title: title, body: body, type: 'info');
    }

    const questTitle = 'Quest Completed! ✅';
    final questBody = 'Great job! You earned $xpToAdd XP.';
    if (isAllOn && isQuestOn) NotificationService().showNotification(id: 3, title: questTitle, body: questBody);
    await _savePersistentNotification(uid, title: questTitle, body: questBody, type: 'quest');
  }

  Future<void> checkAndCreateProfile(
    String uid,
    String email,
    String displayName,
  ) async {
    try {
      final user = await getUserProfile(uid);
      final now = DateTime.now();
      final bool isNewNameGeneric =
          displayName.isEmpty || displayName == 'Scholar';

      String generatedUsername = '';
      if (!isNewNameGeneric) {
        generatedUsername = displayName.toLowerCase().replaceAll(' ', '_');
      }

      if (user == null) {
        final newUser = UserModel(
          uid: uid,
          email: email,
          displayName: !isNewNameGeneric ? displayName : 'Scholar',
          username: generatedUsername,
          lastLogin: now,
          streak: 1,
        );
        await createUserProfile(newUser);
      } else {
        final Map<String, dynamic> updates = {'email': email};
        final bool currentIsGeneric =
            user.displayName.isEmpty || user.displayName == 'Scholar';

        if (currentIsGeneric && !isNewNameGeneric) {
          updates['displayName'] = displayName;
          if (user.username.isEmpty) {
            updates['username'] = generatedUsername;
          }
        } else if (!isNewNameGeneric && displayName != user.displayName) {
          updates['displayName'] = displayName;
        }

        await _db.collection('users').doc(uid).set(updates, SetOptions(merge: true));
        await updateStreak(uid);
      }
    } catch (e) {
      debugPrint('UserService ERROR: Handshake failed: $e');
    }
  }

  Future<void> updateStreak(String uid) async {
    try {
      final user = await getUserProfile(uid);
      if (user == null) return;

      final lastLogin = user.lastLogin;
      final now = DateTime.now();
      final lastLoginDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
      final todayDate = DateTime(now.year, now.month, now.day);
      final difference = todayDate.difference(lastLoginDate).inDays;

      if (difference == 0) return;

      if (difference == 1) {
        await _db.collection('users').doc(uid).update({
          'streak': FieldValue.increment(1),
          'lastLogin': Timestamp.fromDate(now),
        });
        await _savePersistentNotification(uid, title: 'Streak Maintained! 🔥', body: 'You are on fire! Keep it up.', type: 'streak');
      } else {
        await _db.collection('users').doc(uid).update({
          'streak': 1,
          'lastLogin': Timestamp.fromDate(now),
        });
      }
    } catch (e) {
      debugPrint('UserService ERROR: Streak update failed: $e');
    }
  }

  Future<void> updateDisplayName(String uid, String newName) async {
    await _db.collection('users').doc(uid).update({'displayName': newName});
  }

  Future<void> updateFullProfile(
    String uid,
    Map<String, dynamic> profileData,
  ) async {
    try {
      await _db.collection('users').doc(uid).update(profileData);
    } catch (e) {
      debugPrint('UserService ERROR: Failed to update full profile: $e');
      rethrow;
    }
  }

  Future<void> deleteUserAccount(String uid) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == uid) {
        await user.delete();
      }
      await _db.collection('users').doc(uid).delete();
    } catch (e) {
      debugPrint('UserService ERROR: Failed to delete account: $e');
      rethrow;
    }
  }
}
