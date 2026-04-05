import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/core/utils/xp_utils.dart';

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

  Future<void> addXp(String uid, int xpToAdd) async {
    final user = await getUserProfile(uid);
    if (user == null) return;

    final newTotalXp = user.xp + xpToAdd;
    final newLevel = XpUtils.calculateLevel(newTotalXp);

    await updateXp(uid, newTotalXp, newLevel);
  }

  Future<void> checkAndCreateProfile(String uid, String email, String displayName) async {
    debugPrint('UserService: Starting handshake for $uid (Name: $displayName)');
    
    try {
      final user = await getUserProfile(uid);
      final now = DateTime.now();
      final bool isNewNameGeneric = displayName.isEmpty || displayName == 'Scholar';

      if (user == null) {
        debugPrint('UserService: No profile found. Creating new one...');
        final newUser = UserModel(
          uid: uid,
          email: email,
          displayName: !isNewNameGeneric ? displayName : 'Scholar',
          lastLogin: now,
          streak: 1,
        );
        await createUserProfile(newUser);
      } else {
        debugPrint('UserService: Existing profile found. Checking for updates...');
        final Map<String, dynamic> updates = {'email': email};

        final bool currentIsGeneric = user.displayName.isEmpty || user.displayName == 'Scholar';
        
        if (currentIsGeneric && !isNewNameGeneric) {
          debugPrint('UserService: Updating generic name "Scholar" to "$displayName"');
          updates['displayName'] = displayName;
        } else if (!isNewNameGeneric && displayName != user.displayName) {
          debugPrint('UserService: Syncing name change to "$displayName"');
          updates['displayName'] = displayName;
        }

        // We use set with merge:true to be safer than update
        await _db.collection('users').doc(uid).set(updates, SetOptions(merge: true));
        debugPrint('UserService: Handshake complete (updates applied: ${updates.keys.toList()})');
        
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
    await _db.collection('users').doc(uid).update({
      'displayName': newName,
    });
  }

  Future<void> updateFullProfile(String uid, Map<String, dynamic> profileData) async {
    try {
      await _db.collection('users').doc(uid).update(profileData);
      debugPrint('UserService: Profile updated successfully for $uid');
    } catch (e) {
      debugPrint('UserService ERROR: Failed to update full profile: $e');
      rethrow;
    }
  }
}
