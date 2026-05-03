import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/home/services/quest_service.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';

enum QuestDifficulty { easy, medium, hard }

class QuestModel {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final QuestDifficulty difficulty;
  final bool isCompleted;
  final String category; // e.g., 'Flashcards', 'Coding', 'Quiz'
  final int estimatedMinutes; // Used for algorithm weights

  QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.difficulty,
    this.isCompleted = false,
    required this.category,
    this.estimatedMinutes = 10,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'xpReward': xpReward,
      'difficulty': difficulty.name,
      'isCompleted': isCompleted,
      'category': category,
      'estimatedMinutes': estimatedMinutes,
    };
  }

  factory QuestModel.fromMap(Map<String, dynamic> map) {
    return QuestModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      xpReward: map['xpReward'] ?? 0,
      difficulty: QuestDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => QuestDifficulty.easy,
      ),
      isCompleted: map['isCompleted'] ?? false,
      category: map['category'] ?? '',
      estimatedMinutes: map['estimatedMinutes'] ?? 10,
    );
  }
}

final questServiceProvider = Provider<QuestService>((ref) {
  return QuestService();
});

final dailyQuestsProvider = StreamProvider<List<QuestModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  // The service logic now automatically shuffles based on the Current Date.
  return ref.watch(questServiceProvider).getDailyQuests(user.uid);
});
