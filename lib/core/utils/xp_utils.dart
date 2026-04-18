import 'dart:math';

class XpUtils {
  /// ── Level Calculation ──────────────────────────────────────
  /// Simple formula: Level = floor(sqrt(totalXp / 100)) + 1
  /// Example:
  /// 0 XP = Level 1
  /// 100 XP = Level 2
  /// 400 XP = Level 3
  /// 900 XP = Level 4
  static int calculateLevel(int totalXp) {
    if (totalXp <= 0) return 1;
    return (sqrt(totalXp / 100)).floor() + 1;
  }

  /// ── XP for Level ───────────────────────────────────────────
  /// Inverse formula: totalXp = (level - 1)^2 * 100
  static int totalXpForLevel(int level) {
    if (level <= 1) return 0;
    return pow(level - 1, 2).toInt() * 100;
  }

  /// ── Progress within Level ──────────────────────────────────
  /// Returns a map with current level progress details
  static Map<String, dynamic> getLevelProgress(int totalXp) {
    final currentLevel = calculateLevel(totalXp);
    final xpAtStartOfLevel = totalXpForLevel(currentLevel);
    final xpAtEndOfLevel = totalXpForLevel(currentLevel + 1);

    final xpInCurrentLevel = totalXp - xpAtStartOfLevel;
    final xpRequiredForNextLevel = xpAtEndOfLevel - xpAtStartOfLevel;

    final progressFactor = xpInCurrentLevel / xpRequiredForNextLevel;

    return {
      'level': currentLevel,
      'currentLevelXp': xpInCurrentLevel,
      'nextLevelXpThreshold': xpRequiredForNextLevel,
      'progress': progressFactor,
      'totalRemaining': xpAtEndOfLevel - totalXp,
    };
  }

  /// ── Rank Title ─────────────────────────────────────────────
  static String getRankTitle(int level) {
    if (level < 5) return 'Novice Scholar';
    if (level < 10) return 'Code Apprentice';
    if (level < 20) return 'Syntax Sorcerer';
    if (level < 35) return 'Algorithm Architect';
    if (level < 50) return 'Elite Coder';
    return 'Grandmaster of the Void';
  }
}
