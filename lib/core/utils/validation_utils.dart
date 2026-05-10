class ValidationUtils {
  /// Validates an email address and trims whitespace.
  static bool isValidEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(trimmed);
  }

  /// Validates a name (alphabetic, spaces only) and trims whitespace.
  static bool isValidName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    // Allows internal spaces but no leading/trailing
    final nameRegex = RegExp(r'^[a-zA-Z]+(\s[a-zA-Z]+)*$');
    return nameRegex.hasMatch(trimmed);
  }

  /// Validates a password (minimum 8 characters) and trims whitespace.
  static bool isValidPassword(String password) {
    // Note: We trim for length check, but usually passwords allow spaces.
    // However, leading/trailing spaces are almost always accidental user error.
    return password.trim().length >= 8;
  }

  /// Validates a username (alphanumeric and underscores only, 3-30 chars).
  static bool isValidUsername(String username) {
    final trimmed = username.trim();
    if (trimmed.length < 3 || trimmed.length > 30) return false;
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegex.hasMatch(trimmed);
  }

  // Field Limits
  static const int maxDisplayNameLength = 50;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 150;
  static const int maxSchoolLength = 100;
  static const int maxCourseLength = 100;
  static const int maxYearLevelLength = 20;
}
