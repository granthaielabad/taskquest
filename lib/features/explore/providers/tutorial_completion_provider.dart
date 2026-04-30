import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialCompletionNotifier extends Notifier<Set<String>> {
  static const String _key = 'completed_tutorials';

  @override
  Set<String> build() {
    _loadCompletionStatus();
    return {};
  }

  Future<void> _loadCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_key) ?? [];
    state = completed.toSet();
  }

  Future<void> completeTutorial(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.toSet();
    current.add(id);
    await prefs.setStringList(_key, current.toList());
    state = current;
  }

  bool isCompleted(String id) => state.contains(id);
}

final tutorialCompletionProvider =
    NotifierProvider<TutorialCompletionNotifier, Set<String>>(() {
      return TutorialCompletionNotifier();
    });
