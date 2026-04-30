// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/services/sound_service.dart';
import 'package:taskquest/features/games/models/game_models.dart';
import 'package:taskquest/features/games/providers/game_engine_provider.dart';
import 'package:taskquest/features/games/screens/game_results_screen.dart';
import 'package:taskquest/features/games/widgets/game_timer.dart';
import 'package:taskquest/features/shared/widgets/report_dialog.dart';
import 'package:taskquest/features/shared/widgets/exit_confirmation_dialog.dart';
import 'package:taskquest/features/shared/widgets/shake_widget.dart';

class CodeBlocksGameplayScreen extends ConsumerStatefulWidget {
  const CodeBlocksGameplayScreen({super.key});

  @override
  ConsumerState<CodeBlocksGameplayScreen> createState() =>
      _CodeBlocksGameplayScreenState();
}

class _CodeBlocksGameplayScreenState
    extends ConsumerState<CodeBlocksGameplayScreen> {
  final Map<int, String> _placedBlocks = {};
  final SoundService _soundService = SoundService();
  bool _shouldShake = false;

  String _getFilename(GameSessionState state) {
    final language = state.config?.options['Language'] ?? 'Python';
    final index = state.currentQuestionIndex + 1;
    String ext = '.py';
    if (language == 'JavaScript') ext = '.js';
    if (language == 'Java') ext = '.java';
    if (language == 'C++') ext = '.cpp';
    return 'challenge_$index$ext';
  }

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
              gameTitle: next.config?.title ?? 'Code Blocks',
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
          setState(() {
            _placedBlocks.clear();
            _shouldShake = true;
          });
        }
      }

      // Clear local state when moving to next question
      if (next.status == GameSessionStatus.playing &&
          previous?.status == GameSessionStatus.showingFeedback) {
        setState(() => _placedBlocks.clear());
      }
    });

    if (gameState.status == GameSessionStatus.loading ||
        gameState.currentQuestion == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = gameState.currentQuestion as CodeBlockPuzzle;
    final isAnswered = gameState.status == GameSessionStatus.showingFeedback;

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
                                gameType: 'code_blocks',
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

                      // Code Editor
                      ShakeWidget(
                        shake: _shouldShake,
                        onShakeComplete: () =>
                            setState(() => _shouldShake = false),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1C1E),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Window Header
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Row(
                                      children: List.generate(
                                        3,
                                        (i) => Container(
                                          margin: const EdgeInsets.only(
                                            right: 6,
                                          ),
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.white12,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _getFilename(gameState),
                                      style: const TextStyle(
                                        fontFamily: 'DM Mono',
                                        fontSize: 10,
                                        color: Colors.white24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Code Body
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  0,
                                  24,
                                  32,
                                ),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: _buildCodePuzzles(
                                    question,
                                    isAnswered,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      Text(
                        'AVAILABLE BLOCKS',
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 10,
                          letterSpacing: 1.2,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Options
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: question.availableBlocks.map((opt) {
                          final isUsed = _placedBlocks.containsValue(opt);
                          return Draggable<String>(
                            data: opt,
                            maxSimultaneousDrags: isAnswered || isUsed ? 0 : 1,
                            feedback: _buildBlock(opt, isDragging: true),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildBlock(opt),
                            ),
                            child: Opacity(
                              opacity: isUsed ? 0.3 : 1.0,
                              child: _buildBlock(opt),
                            ),
                          );
                        }).toList(),
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
                                    ? 'Success!'
                                    : 'Broken Logic',
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

  List<Widget> _buildCodePuzzles(CodeBlockPuzzle question, bool isAnswered) {
    List<Widget> widgets = [];
    for (int i = 0; i < question.codeSegments.length; i++) {
      final segment = question.codeSegments[i];
      if (segment == 'slot') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DragTarget<String>(
              onAcceptWithDetails: (details) {
                if (isAnswered) return;
                setState(() {
                  _placedBlocks[i] = details.data;
                });
                // If all slots filled, submit
                int slotCount = question.codeSegments
                    .where((s) => s == 'slot')
                    .length;
                if (_placedBlocks.length == slotCount) {
                  ref
                      .read(gameEngineProvider.notifier)
                      .submitAnswer(_placedBlocks);
                }
              },
              builder: (context, candidate, _) {
                final value = _placedBlocks[i];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: value != null
                        ? Colors.white12
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: value != null ? Colors.white30 : Colors.white12,
                      style: BorderStyle.solid,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 60,
                    minHeight: 28,
                  ),
                  child: Center(
                    child: Text(
                      value ?? '???',
                      style: TextStyle(
                        color: value != null ? Colors.white : Colors.white24,
                        fontFamily: 'DM Mono',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        widgets.add(
          Text(
            segment,
            style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 14,
              color: Colors.white,
              height: 1.8,
            ),
          ),
        );
      }
    }
    return widgets;
  }

  Widget _buildBlock(String label, {bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E1DC)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111111),
        ),
      ),
    );
  }
}
