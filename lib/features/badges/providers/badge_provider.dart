import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/badges/services/badge_service.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';

class BadgeModel {
  final String id;
  final String title;
  final String description;
  final String icon; // Icon name or SVG path
  final bool isUnlocked;
  final DateTime? unlockedAt;

  BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory BadgeModel.fromMap(
    Map<String, dynamic> map,
    bool unlocked,
    DateTime? date,
  ) {
    return BadgeModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      isUnlocked: unlocked,
      unlockedAt: date,
    );
  }
}

final badgeServiceProvider = Provider<BadgeService>((ref) {
  return BadgeService();
});

final userBadgesProvider = FutureProvider<List<BadgeModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(badgeServiceProvider).getUserBadges(user.uid);
});
