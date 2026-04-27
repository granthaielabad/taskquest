import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalkthroughNotifier extends Notifier<bool> {
  static const String _key = 'has_seen_walkthrough';

  @override
  bool build() {
    _checkStatus();
    return true; // Keep true initially to prevent flash, but we'll fix the trigger logic
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(_key) ?? false;
    state = hasSeen;
  }

  Future<void> completeWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = true;
  }

  Future<void> resetWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
    state = false;
  }
}

final walkthroughProvider = NotifierProvider<WalkthroughNotifier, bool>(() {
  return WalkthroughNotifier();
});

class WalkthroughKeys {
  static final greetingKey = GlobalKey();
  static final notificationKey = GlobalKey();
  static final streakKey = GlobalKey();
  static final leaderboardCardKey = GlobalKey();
  static final badgesCardKey = GlobalKey();
  static final challengesKey = GlobalKey();
  static final gamesKey = GlobalKey();
  static final recentActivityKey = GlobalKey();
  
  static final navHomeKey = GlobalKey();
  static final navGamesKey = GlobalKey();
  static final navScanKey = GlobalKey();
  static final navExploreKey = GlobalKey();
  static final navProfileKey = GlobalKey();
}
