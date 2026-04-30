// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/services/sound_service.dart';
import 'package:taskquest/features/games/models/game_models.dart';
import 'package:taskquest/features/games/providers/game_engine_provider.dart';
import 'package:taskquest/features/games/screens/game_results_screen.dart';
import 'package:taskquest/features/games/widgets/game_timer.dart';
import 'package:taskquest/features/shared/widgets/exit_confirmation_dialog.dart';
import 'package:taskquest/features/shared/widgets/report_dialog.dart';
import 'package:taskquest/features/shared/widgets/shake_widget.dart';

class QuizGameplayScreen extends ConsumerStatefulWidget {
  const QuizGameplayScreen({super.key});

  @override
  ConsumerState<QuizGameplayScreen> createState() => _QuizGameplayScreenState();
}

class _QuizGameplayScreenState extends ConsumerState<QuizGameplayScreen> {
  final SoundService _soundService = SoundService();
  bool _shouldShake = false;

  Future<void> _showExitConfirmation() async {
    ref.read(gameEngineProvider.notifier).pauseGame();
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => const ExitConfirmationDialog(),
    );

    if (shouldExit ?? false) {
      ref.read(gameEngineProvider.notifier).finishGame();
      if (mounted) Navigator.pop(context);
    } else {
      ref.read(gameEngineProvider.notifier).resumeGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameEngineProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Listen for game finished to navigate to results
    ref.listen(gameEngineProvider, (previous, next) {
      if (next.status == GameSessionStatus.finished &&
          previous?.status != GameSessionStatus.finished) {
        final result = ref.read(gameEngineProvider.notifier).calculateResult();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GameResultsScreen(
              result: result,
              gameTitle: next.config?.title ?? 'Quiz',
            ),
          ),
        );
      }

      // Play sounds on feedback
      if (next.status == GameSessionStatus.showingFeedback &&
          previous?.status != GameSessionStatus.showingFeedback) {
        if (next.lastAnswerCorrect == true) {
          HapticFeedback.mediumImpact();
          _soundService.playCorrect();
        } else {
          HapticFeedback.heavyImpact();
          _soundService.playWrong();
          setState(() => _shouldShake = true);
        }
      }

      if (next.status == GameSessionStatus.playing &&
          previous?.status == GameSessionStatus.showingFeedback) {
        setState(() => _shouldShake = false);
      }
    });

    if (gameState.status == GameSessionStatus.loading ||
        gameState.currentQuestion == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = gameState.currentQuestion as QuizQuestion;
    final isAnswered = gameState.status == GameSessionStatus.showingFeedback;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _showExitConfirmation();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _showExitConfirmation,
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: const Text(
                        'Exit',
                        style: TextStyle(fontFamily: 'DM Mono'),
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          gameState.questions.length,
                          (i) => Container(
                            margin: const EdgeInsets.only(left: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i <= gameState.currentQuestionIndex
                                  ? (i < gameState.currentQuestionIndex
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurface.withValues(
                                            alpha: 0.5,
                                          ))
                                  : colorScheme.outline.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${gameState.currentQuestionIndex + 1} / ${gameState.questions.length}',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(
                            Icons.flag_outlined,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () async {
                            ref.read(gameEngineProvider.notifier).pauseGame();
                            await showDialog(
                              context: context,
                              builder: (context) => ReportDialog(
                                gameType: 'quiz',
                                contentId: question.id,
                              ),
                            );
                            ref.read(gameEngineProvider.notifier).resumeGame();
                          },
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GameTimer(
                        timeLeft: gameState.timeLeft,
                        totalTime: gameState.totalTime,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        question.instruction.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 10,
                          letterSpacing: 1.2,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Question Code Card
                      ShakeWidget(
                        shake: _shouldShake,
                        onShakeComplete: () =>
                            setState(() => _shouldShake = false),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1C1E),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            question.codeSnippet,
                            style: const TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 14,
                              color: Colors.white,
                              height: 1.8,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Options
                      ...question.options.asMap().entries.map((e) {
                        final label = String.fromCharCode(
                          65 + e.key,
                        ); // A, B, C...
                        return _buildOption(
                          context,
                          ref,
                          label,
                          e.value,
                          question.correctAnswer,
                          gameState,
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Feedback Toast
              if (isAnswered)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: gameState.lastAnswerCorrect == true
                          ? Colors.green.shade900
                          : Colors.red.shade900,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            gameState.lastAnswerCorrect == true
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gameState.lastAnswerCorrect == true
                                    ? 'Correct!'
                                    : 'Not quite...',
                                style: const TextStyle(
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                question.explanation,
                                style: TextStyle(
                                  fontFamily: 'DM Mono',
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    String value,
    String correct,
    GameSessionState state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isShowingFeedback = state.status == GameSessionStatus.showingFeedback;
    final isCorrect = isShowingFeedback && value == correct;
    final isWrong =
        isShowingFeedback && state.lastAnswer == value && value != correct;

    Color bgColor = colorScheme.surface;
    Color borderColor = colorScheme.outline;
    Color textColor = colorScheme.onSurface;

    if (isCorrect) {
      bgColor = Colors.green.shade900;
      borderColor = Colors.green;
      textColor = Colors.white;
    } else if (isWrong) {
      bgColor = Colors.red.shade900;
      borderColor = Colors.red;
      textColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: isShowingFeedback
            ? null
            : () => ref.read(gameEngineProvider.notifier).submitAnswer(value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: borderColor,
              width: isShowingFeedback ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isShowingFeedback
                      ? Colors.white.withValues(alpha: 0.1)
                      : colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: isShowingFeedback
                          ? Colors.white
                          : colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),
              if (isCorrect)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              if (isWrong)
                const Icon(Icons.cancel_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
