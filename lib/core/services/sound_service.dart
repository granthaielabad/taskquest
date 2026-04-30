// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  // ── Predefined Sound Paths ───────────────────────────────────
  // Note: For audioplayers 6+, use simple paths relative to 'assets/'
  static const String levelUp = 'sounds/levelup.mp3';
  static const String correct = 'sounds/correct.mp3';
  static const String wrong = 'sounds/wrong.mp3';
  static const String tap = 'sounds/tap.mp3';

  Future<void> playSound(String assetPath) async {
    try {
      // AssetSource automatically looks in the 'assets' folder.
      // Do NOT include 'assets/' in the string path.
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing sound ($assetPath): $e');
    }
  }

  // ── Helper Methods ───────────────────────────────────────────
  void playLevelUp() => playSound(levelUp);
  void playCorrect() => playSound(correct);
  void playWrong() => playSound(wrong);
  void playTap() => playSound(tap);
}
