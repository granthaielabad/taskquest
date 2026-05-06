import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/home/providers/activity_provider.dart';
import 'package:taskquest/features/games/models/game_models.dart';
import 'package:taskquest/features/games/services/game_content_service.dart';
import 'package:taskquest/features/home/providers/quest_provider.dart';

final gameContentServiceProvider = Provider((ref) => GameContentService());

class GameSessionState {
  final GameSessionStatus status;
  final GameSessionConfig? config;
  final List<GameQuestion> questions;
  final int currentQuestionIndex;
  final int score;
  final int timeLeft;
  final int totalTime;
  final bool? lastAnswerCorrect;
  final dynamic lastAnswer;
  final DateTime? startTime;

  GameSessionState({
    this.status = GameSessionStatus.idle,
    this.config,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.timeLeft = 30,
    this.totalTime = 30,
    this.lastAnswerCorrect,
    this.lastAnswer,
    this.startTime,
  });

  GameSessionState copyWith({
    GameSessionStatus? status,
    GameSessionConfig? config,
    List<GameQuestion>? questions,
    int? currentQuestionIndex,
    int? score,
    int? timeLeft,
    int? totalTime,
    bool? lastAnswerCorrect,
    dynamic lastAnswer,
    DateTime? startTime,
  }) {
    return GameSessionState(
      status: status ?? this.status,
      config: config ?? this.config,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      totalTime: totalTime ?? this.totalTime,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
      lastAnswer: lastAnswer ?? this.lastAnswer,
      startTime: startTime ?? this.startTime,
    );
  }

  GameQuestion? get currentQuestion =>
      questions.isNotEmpty && currentQuestionIndex < questions.length
      ? questions[currentQuestionIndex]
      : null;
}

class GameEngineNotifier extends Notifier<GameSessionState> {
  Timer? _timer;
  Timer? _autoAdvanceTimer;

  @override
  GameSessionState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _autoAdvanceTimer?.cancel();
    });
    return GameSessionState();
  }

  Future<void> initializeGame(GameSessionConfig config) async {
    state = GameSessionState(status: GameSessionStatus.loading, config: config);

    try {
      final contentService = ref.read(gameContentServiceProvider);
      final questions = await contentService.fetchContent(config);
      final initialTime = _calculateInitialTime(config);

      state = state.copyWith(
        status: GameSessionStatus.playing,
        questions: questions,
        timeLeft: initialTime,
        totalTime: initialTime,
        startTime: DateTime.now(),
      );

      _startTimer();
    } catch (e) {
      state = state.copyWith(status: GameSessionStatus.finished);
    }
  }

  int _calculateInitialTime(GameSessionConfig config) {
    // Check various common keys used for time limits across different modes
    final timeStr =
        config.options['Time'] ??
        config.options['Time Limit'] ??
        config.options['Time per Question'] ??
        '30s';
    final seconds = int.tryParse(timeStr.replaceAll('s', '')) ?? 30;
    return seconds;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else {
        submitAnswer(null); // Time out
      }
    });
  }

  void pauseGame() {
    if (state.status == GameSessionStatus.playing) {
      _timer?.cancel();
      state = state.copyWith(status: GameSessionStatus.paused);
    } else if (state.status == GameSessionStatus.showingFeedback) {
      _autoAdvanceTimer?.cancel();
      state = state.copyWith(status: GameSessionStatus.paused);
    }
  }

  void resumeGame() {
    if (state.status == GameSessionStatus.paused) {
      // Determine if we were playing or showing feedback
      if (state.lastAnswerCorrect != null || state.lastAnswer != null) {
        state = state.copyWith(status: GameSessionStatus.showingFeedback);
        _startAutoAdvance();
      } else {
        state = state.copyWith(status: GameSessionStatus.playing);
        _startTimer();
      }
    }
  }

  void submitAnswer(dynamic answer) {
    if (state.status != GameSessionStatus.playing) return;
    _timer?.cancel();

    final isCorrect = state.currentQuestion?.validate(answer) ?? false;
    final newScore = isCorrect ? state.score + 1 : state.score;

    state = state.copyWith(
      status: GameSessionStatus.showingFeedback,
      lastAnswerCorrect: isCorrect,
      lastAnswer: answer,
      score: newScore,
    );

    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(seconds: 3), () {
      nextQuestion();
    });
  }

  void nextQuestion() {
    _autoAdvanceTimer?.cancel();
    if (state.currentQuestionIndex + 1 < state.questions.length) {
      state = state.copyWith(
        status: GameSessionStatus.playing,
        currentQuestionIndex: state.currentQuestionIndex + 1,
        timeLeft: state.totalTime,
        lastAnswerCorrect: null,
        lastAnswer: null,
      );
      _startTimer();
    } else {
      finishGame();
    }
  }

  void finishGame() {
    _timer?.cancel();
    _autoAdvanceTimer?.cancel();

    final result = calculateResult();
    state = state.copyWith(status: GameSessionStatus.finished);

    // Save results to user profile and record activity
    _saveResults(result);
  }

  Future<void> _saveResults(GameResult result) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    try {
      // 1. Add XP
      await ref.read(userServiceProvider).addXp(user.uid, result.xpEarned);

      // 2. Record Activity
      final activity = ActivityModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Completed ${state.config?.title ?? "Game"}',
        subtitle:
            'Scored ${result.score}/${result.totalQuestions} with ${(result.accuracy * 100).toInt()}% accuracy.',
        xpReward: result.xpEarned,
        type: ActivityType.game,
        timestamp: DateTime.now(),
      );
      await ref.read(activityServiceProvider).recordActivity(user.uid, activity);

      // 3. COMPLETE RELEVANT QUESTS AUTOMATICALLY
      final questService = ref.read(questServiceProvider);

      final gameType = state.config?.type;
      final difficulty = state.config?.options['Difficulty'];

      if (gameType == GameType.codeBlocks) {
        await questService.completeQuestsByType(user.uid, 'CODING', accuracy: result.accuracy, difficulty: difficulty);
      } else if (gameType == GameType.quiz) {
        await questService.completeQuestsByType(user.uid, 'QUIZ', accuracy: result.accuracy, difficulty: difficulty);
      } else if (gameType == GameType.sdlc) {
        await questService.completeQuestsByType(user.uid, 'ARCHITECTURE', accuracy: result.accuracy, difficulty: difficulty);
      } else if (gameType == GameType.algorithm) {
        await questService.completeQuestsByType(user.uid, 'LOGIC', accuracy: result.accuracy, difficulty: difficulty);
        await questService.completeQuestsByType(user.uid, 'CS BASICS', accuracy: result.accuracy, difficulty: difficulty);
      }
      await ref
          .read(activityServiceProvider)
          .recordActivity(user.uid, activity);
    } catch (e) {
      debugPrint('Error saving game results: $e');
    }
  }

  GameResult calculateResult() {
    final totalXp = state.questions.fold<int>(0, (sum, q) => sum + q.xpReward);
    final xpEarned = state.questions.isEmpty
        ? 0
        : (totalXp * (state.score / state.questions.length)).round();
    final accuracy = state.questions.isEmpty
        ? 0.0
        : state.score / state.questions.length;

    return GameResult(
      score: state.score,
      totalQuestions: state.questions.length,
      xpEarned: xpEarned,
      timeTaken: state.startTime != null
          ? DateTime.now().difference(state.startTime!)
          : Duration.zero,
      accuracy: accuracy,
    );
  }
}

final gameEngineProvider =
    NotifierProvider<GameEngineNotifier, GameSessionState>(() {
      return GameEngineNotifier();
    });
