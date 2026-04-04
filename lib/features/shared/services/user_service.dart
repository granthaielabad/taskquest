import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';

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
}
