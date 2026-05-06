import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/utils/algorithms.dart';
import 'package:taskquest/features/home/providers/quest_provider.dart';

class QuestOptimizerNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void optimizeQuests(List<QuestModel> availableQuests, int timeLimit) {
    if (availableQuests.isEmpty) {
      state = [];
      return;
    }

    // Filter out already completed quests
    final activeQuests = availableQuests.where((q) => !q.isCompleted).toList();
    if (activeQuests.isEmpty) {
      state = [];
      return;
    }

    // Prepare inputs for Knapsack Algorithm
    final weights = activeQuests.map((q) => q.estimatedMinutes).toList();
    final values = activeQuests.map((q) => q.xpReward).toList();

    // Application of Algorithm 3: 0/1 KNAPSACK (O(N * W))
    final selectedIndices = TaskQuestAlgorithms.knapsackDP(
      timeLimit,
      weights,
      values,
    );

    // Map indices back to Quest IDs
    state = selectedIndices.map((index) => activeQuests[index].id).toList();
  }

  void clearOptimization() {
    state = [];
  }
}

final questOptimizerProvider = NotifierProvider<QuestOptimizerNotifier, List<String>>(() {
  return QuestOptimizerNotifier();
});
