import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/games/models/game_models.dart';
import 'package:taskquest/features/games/providers/game_engine_provider.dart';
import 'package:taskquest/features/games/screens/game_results_screen.dart';
import 'package:taskquest/features/shared/widgets/report_dialog.dart';
import 'package:taskquest/features/shared/widgets/exit_confirmation_dialog.dart';
import 'package:taskquest/features/shared/widgets/shake_widget.dart';

class SyntaxSniperGameplayScreen extends ConsumerStatefulWidget {
  const SyntaxSniperGameplayScreen({super.key});

  @override
  ConsumerState<SyntaxSniperGameplayScreen> createState() =>
      _SyntaxSniperGameplayScreenState();
}

class _SyntaxSniperGameplayScreenState
    extends ConsumerState<SyntaxSniperGameplayScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int _lives = 3;
  late List<SyntaxQuestion> _questions;
  bool _isGameOver = false;
  bool _shouldShake = false;
  bool _isPaused = false;
  Timer? _timer;
  int _timeLeft = 10;
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _setupGame();
    _stopwatch.start();
    _startTimer();
  }

  void _setupGame() {
    final gameState = ref.read(gameEngineProvider);
    final questionsConfig =
        int.tryParse(gameState.config?.options['Questions'] ?? '10') ?? 10;

    // Convert generic List<GameQuestion> to List<SyntaxQuestion>
    _questions = gameState.questions
        .whereType<SyntaxQuestion>()
        .take(questionsConfig)
        .toList();

    // Safety check: if pool is empty for some reason, finish game
    if (_questions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused || _isGameOver) return;
      if (_timeLeft == 0) {
        _handleAnswer(null); // Time out counts as wrong
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _handleAnswer(bool? userAnswer) {
    if (_isGameOver || _isPaused) return;

    final question = _questions[_currentIndex];
    final bool isCorrect = (userAnswer == question.hasError);

    if (isCorrect) {
      _score += question.xpReward;
      _correctAnswers++;
      HapticFeedback.mediumImpact();
    } else {
      _lives--;
      setState(() => _shouldShake = true);
      HapticFeedback.heavyImpact();
    }

    if (_lives <= 0 || _currentIndex >= _questions.length - 1) {
      _endGame();
    } else {
      setState(() {
        _currentIndex++;
        _startTimer();
      });
    }
  }

  void _endGame() {
    _isGameOver = true;
    _timer?.cancel();
    _stopwatch.stop();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameResultsScreen(
          result: GameResult(
            score: _correctAnswers,
            totalQuestions: _questions.length,
            xpEarned: _score,
            timeTaken: _stopwatch.elapsed,
            accuracy: (_correctAnswers / _questions.length),
          ),
          gameTitle: 'Syntax Sniper',
        ),
      ),
    );
  }

  Future<void> _showReport() async {
    setState(() => _isPaused = true);
    await showDialog(
      context: context,
      builder: (context) => ReportDialog(
        gameType: 'syntax_sniper',
        contentId: _questions[_currentIndex].id,
      ),
    );
    setState(() => _isPaused = false);
  }

  Future<bool> _showExitConfirmation() async {
    setState(() => _isPaused = true);
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => const ExitConfirmationDialog(),
    );
    if (shouldExit ?? false) {
      return true;
    } else {
      setState(() => _isPaused = false);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) return const Scaffold();

    final colorScheme = Theme.of(context).colorScheme;
    final currentQuestion = _questions[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header: Exit, Progress, Report
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        if (await _showExitConfirmation() && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: const Text(
                        'Exit',
                        style: TextStyle(fontFamily: 'DM Mono'),
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1} / ${_questions.length}',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.flag_outlined,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: _showReport,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              // Stats: Time, XP, Lives
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _HeaderInfo(
                      label: 'TIME',
                      value: '${_timeLeft}s',
                      color: _timeLeft < 4 ? Colors.red : colorScheme.primary,
                    ),
                    _HeaderInfo(label: 'XP', value: '$_score'),
                    Row(
                      children: List.generate(
                        3,
                        (index) => Icon(
                          index < _lives
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Instruction
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'SNIPE THE ERROR!',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    letterSpacing: 2,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Language: ${currentQuestion.instruction}',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 40),

              // Code Snippet Box with Shake
              Expanded(
                child: ShakeWidget(
                  shake: _shouldShake,
                  onShakeComplete: () => setState(() => _shouldShake = false),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        currentQuestion.codeSnippet,
                        style: const TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Control Buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: _SniperButton(
                        label: 'NO ERROR',
                        color: Colors.greenAccent,
                        onTap: () => _handleAnswer(false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SniperButton(
                        label: 'HAS ERROR',
                        color: Colors.redAccent,
                        onTap: () => _handleAnswer(true),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _HeaderInfo({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 9,
            letterSpacing: 1.5,
            color: AppTheme.muted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: color ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SniperButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SniperButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
