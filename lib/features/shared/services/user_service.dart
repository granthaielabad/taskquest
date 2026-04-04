import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/core/utils/xp_utils.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
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
    final user = await getUserProfile(uid);
    if (user == null) {
      final newUser = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        lastLogin: DateTime.now(),
        streak: 1, // Start with 1 on signup
      );
      await createUserProfile(newUser);
    } else {
      // Existing user, update streak
      await updateStreak(uid);
    }
  }

  Future<void> updateStreak(String uid) async {
    final user = await getUserProfile(uid);
    if (user == null) return;

    final lastLogin = user.lastLogin;
    final now = DateTime.now();
    
    // Normalize dates to mid-night for comparison
    final lastLoginDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
    final todayDate = DateTime(now.year, now.month, now.day);
    
    final difference = todayDate.difference(lastLoginDate).inDays;

    if (difference == 0) {
      // Already logged in today, do nothing
      return;
    } else if (difference == 1) {
      // Consecutive day!
      await _db.collection('users').doc(uid).update({
        'streak': FieldValue.increment(1),
        'lastLogin': Timestamp.fromDate(now),
      });
    } else {
      // Streak broken :(
      await _db.collection('users').doc(uid).update({
        'streak': 1,
        'lastLogin': Timestamp.fromDate(now),
      });
    }
  }

  Future<void> updateDisplayName(String uid, String newName) async {
    await _db.collection('users').doc(uid).update({
      'displayName': newName,
    });
  }
}
