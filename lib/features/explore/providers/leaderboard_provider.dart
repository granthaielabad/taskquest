import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/utils/algorithms.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';

final leaderboardProvider = StreamProvider<List<UserModel>>((ref) {
  // We fetch without orderBy to demonstrate our custom QuickSort algorithm
  return FirebaseFirestore.instance
      .collection('users')
      .limit(50)
      .snapshots()
      .map((snapshot) {
        final users = snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList();

        // Application of Algorithm 1: QUICK SORT (O(N log N))
        // Sorting by streak descending.
        if (users.isNotEmpty) {
          TaskQuestAlgorithms.quickSort<UserModel>(
            users,
            0,
            users.length - 1,
            (a, b) => b.streak.compareTo(a.streak), // Descending
          );
        }

        // Limit to top 20 after sorting
        return users.take(20).toList();
      });
});
