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

class SdlcGameplayScreen extends ConsumerStatefulWidget {
  const SdlcGameplayScreen({super.key});

  @override
  ConsumerState<SdlcGameplayScreen> createState() => _SdlcGameplayScreenState();
}

class _SdlcGameplayScreenState extends ConsumerState<SdlcGameplayScreen> {
  final List<String> _placedPhases = [];
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
              gameTitle: next.config?.title ?? 'SDLC Sequence',
            ),
          ),
        );
      }

      if (next.status == GameSessionStatus.showingFeedback &&
          previous?.status != GameSessionStatus.showingFeedback) {
        if (next.lastAnswerCorrect == true) {
          HapticFeedback.mediumImpact();
          _soundService.playCorrect();
        } else {
          HapticFeedback.heavyImpact();
          _soundService.playWrong();
          // Reset on wrong
          setState(() {
            _placedPhases.clear();
            _shouldShake = true;
          });
        }
      }

      // Clear local state when moving to next question
      if (next.status == GameSessionStatus.playing &&
          previous?.status == GameSessionStatus.showingFeedback) {
        setState(() {
          _placedPhases.clear();
          _shouldShake = false;
        });
      }
    });

    if (gameState.status == GameSessionStatus.loading ||
        gameState.currentQuestion == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = gameState.currentQuestion as SdlcSequence;
    final isAnswered = gameState.status == GameSessionStatus.showingFeedback;

    // Remaining phases to be placed
    final availablePhases = question.shuffledPhases
        .where((p) => !_placedPhases.contains(p))
        .toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _showExitConfirmation();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
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
                                gameType: 'sdlc',
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

                      // Placed Phases
                      ..._placedPhases.asMap().entries.map(
                        (e) => _buildPlacedCard(context, e.key + 1, e.value),
                      ),

                      // Drop Target
                      ShakeWidget(
                        shake: _shouldShake,
                        onShakeComplete: () =>
                            setState(() => _shouldShake = false),
                        child: Column(
                          children: [
                            if (!isAnswered &&
                                _placedPhases.length <
                                    question.correctOrder.length)
                              DragTarget<String>(
                                onAcceptWithDetails: (d) {
                                  setState(() {
                                    _placedPhases.add(d.data);
                                  });
                                  if (_placedPhases.length ==
                                      question.correctOrder.length) {
                                    ref
                                        .read(gameEngineProvider.notifier)
                                        .submitAnswer(_placedPhases);
                                  }
                                },
                                builder: (context, candidate, _) => Container(
                                  width: double.infinity,
                                  height: 72,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: colorScheme.outline,
                                      width: 1.5,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.question_mark_rounded,
                                            size: 14,
                                            color: colorScheme.onSurfaceVariant
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Drop next phase here...',
                                          style: TextStyle(
                                            fontFamily: 'DM Mono',
                                            fontSize: 12,
                                            color: colorScheme.onSurfaceVariant
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            // Available
                            if (!isAnswered)
                              ...availablePhases.map(
                                (p) => Draggable<String>(
                                  data: p,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width -
                                          48,
                                      child: _buildDraggableCard(
                                        context,
                                        p,
                                        isDragging: true,
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.3,
                                    child: _buildDraggableCard(context, p),
                                  ),
                                  child: _buildDraggableCard(context, p),
                                ),
                              ),
                          ],
                        ),
                      ),
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
                                    ? 'Perfect Order!'
                                    : 'Logical Error',
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

  Widget _buildPlacedCard(BuildContext context, int index, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  color: colorScheme.surface,
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: colorScheme.surface,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.check_rounded,
            color: colorScheme.surface.withValues(alpha: 0.5),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableCard(
    BuildContext context,
    String title, {
    bool isDragging = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.square_rounded,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
              size: 14,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
