// Copyright (c) 2026 TaskQuest. All rights reserved.

enum GameSessionStatus {
  idle,
  loading,
  playing,
  paused,
  showingFeedback,
  finished,
}

enum GameType { quiz, codeBlocks, sdlc, algorithm, syntaxSniper }

class GameSessionConfig {
  final String title;
  final GameType type;
  final Map<String, String> options;

  GameSessionConfig({
    required this.title,
    required this.type,
    required this.options,
  });
}

abstract class GameQuestion {
  final String id;
  final String instruction;
  final String explanation;
  final int xpReward;

  GameQuestion({
    required this.id,
    required this.instruction,
    required this.explanation,
    this.xpReward = 10,
  });

  bool validate(dynamic answer);
}

class QuizQuestion extends GameQuestion {
  final String codeSnippet;
  final String correctAnswer;
  final List<String> options;

  QuizQuestion({
    required super.id,
    required super.instruction,
    required super.explanation,
    required this.codeSnippet,
    required this.correctAnswer,
    required this.options,
    super.xpReward,
  });

  @override
  bool validate(dynamic answer) => answer == correctAnswer;
}

class CodeBlockPuzzle extends GameQuestion {
  final List<String>
  codeSegments; // e.g., ["for (int i=0; i < ", "slot", "; i++)"]
  final List<String> availableBlocks;
  final Map<int, String> correctAnswers; // map index of "slot" to correct block

  CodeBlockPuzzle({
    required super.id,
    required super.instruction,
    required super.explanation,
    required this.codeSegments,
    required this.availableBlocks,
    required this.correctAnswers,
    super.xpReward,
  });

  @override
  bool validate(dynamic answer) {
    if (answer is! Map<int, String>) return false;
    if (answer.length != correctAnswers.length) return false;
    for (var key in correctAnswers.keys) {
      if (answer[key] != correctAnswers[key]) return false;
    }
    return true;
  }
}

class SdlcSequence extends GameQuestion {
  final List<String> correctOrder;
  final List<String> shuffledPhases;

  SdlcSequence({
    required super.id,
    required super.instruction,
    required super.explanation,
    required this.correctOrder,
    required this.shuffledPhases,
    super.xpReward,
  });

  @override
  bool validate(dynamic answer) {
    if (answer is! List<String>) return false;
    if (answer.length != correctOrder.length) return false;
    for (int i = 0; i < correctOrder.length; i++) {
      if (answer[i] != correctOrder[i]) return false;
    }
    return true;
  }
}

class AlgorithmProblem extends GameQuestion {
  final String pseudocode;
  final String question;
  final String correctAnswer;
  final List<String> options;

  AlgorithmProblem({
    required super.id,
    required super.instruction,
    required super.explanation,
    required this.pseudocode,
    required this.question,
    required this.correctAnswer,
    required this.options,
    super.xpReward,
  });

  @override
  bool validate(dynamic answer) => answer == correctAnswer;
}

class SyntaxQuestion extends GameQuestion {
  final String codeSnippet;
  final bool hasError;
  final String? errorLine; // The specific line or part that is wrong

  SyntaxQuestion({
    required super.id,
    required super.instruction,
    required super.explanation,
    required this.codeSnippet,
    required this.hasError,
    this.errorLine,
    super.xpReward,
  });

  @override
  bool validate(dynamic answer) => answer == hasError;
}

class GameResult {
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final Duration timeTaken;
  final double accuracy;

  GameResult({
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    required this.timeTaken,
    required this.accuracy,
  });
}
