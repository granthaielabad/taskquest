class AppConstants {
  // XP per task difficulty
  static const int xpEasy = 10;
  static const int xpMedium = 25;
  static const int xpHard = 50;

  // XP required per level
  static const List<int> levelThresholds = [
    0,    // Level 1
    100,  // Level 2
    250,  // Level 3
    500,  // Level 4
    1000, // Level 5
    2000, // Level 6
    3500, // Level 7
    5500, // Level 8
    8000, // Level 9
    12000,// Level 10
  ];

  static int getLevelFromXP(int xp) {
    for (int i = levelThresholds.length - 1; i >= 0; i--) {
      if (xp >= levelThresholds[i]) return i + 1;
    }
    return 1;
  }

  static int xpToNextLevel(int xp) {
    final level = getLevelFromXP(xp);
    if (level >= levelThresholds.length) return 0;
    return levelThresholds[level] - xp;
  }
}