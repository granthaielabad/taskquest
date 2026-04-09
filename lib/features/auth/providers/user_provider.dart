import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/shared/services/user_service.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String username;
  final String photoUrl;
  final String bio;
  final String school;
  final String course;
  final String yearLevel;
  final int level;
  final int xp;
  final int streak;
  final List<String> unlockedBadges;
  final DateTime lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.username = '',
    this.photoUrl = '',
    this.bio = '',
    this.school = '',
    this.course = '',
    this.yearLevel = '',
    this.level = 1,
    this.xp = 0,
    this.streak = 0,
    this.unlockedBadges = const [],
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'username': username,
      'photoUrl': photoUrl,
      'bio': bio,
      'school': school,
      'course': course,
      'yearLevel': yearLevel,
      'level': level,
      'xp': xp,
      'streak': streak,
      'unlockedBadges': unlockedBadges,
      'lastLogin': Timestamp.fromDate(lastLogin),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      username: map['username'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      bio: map['bio'] ?? '',
      school: map['school'] ?? '',
      course: map['course'] ?? '',
      yearLevel: map['yearLevel'] ?? '',
      level: map['level'] ?? 1,
      xp: map['xp'] ?? 0,
      streak: map['streak'] ?? 0,
      unlockedBadges: List<String>.from(map['unlockedBadges'] ?? []),
      lastLogin: (map['lastLogin'] as Timestamp).toDate(),
    );
  }

  UserModel copyWith({
    String? displayName,
    String? username,
    String? photoUrl,
    String? bio,
    String? school,
    String? course,
    String? yearLevel,
    int? level,
    int? xp,
    int? streak,
    List<String>? unlockedBadges,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      school: school ?? this.school,
      course: course ?? this.course,
      yearLevel: yearLevel ?? this.yearLevel,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(authState.uid)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
});
