import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/home/providers/activity_provider.dart';
import 'package:taskquest/features/badges/providers/badge_provider.dart';
import 'package:taskquest/core/services/sound_service.dart';
import 'package:taskquest/features/games/widgets/game_timer.dart';
import 'package:taskquest/features/shared/widgets/report_dialog.dart';

class QuizQuestion {
  final String id;
  final String code;
  final String correctAnswer;
  final List<String> options;
  final String description;

  QuizQuestion({
    required this.id,
    required this.code,
    required this.correctAnswer,
    required this.options,
    required this.description,
  });
}

class QuizGameplayScreen extends ConsumerStatefulWidget {
  const QuizGameplayScreen({super.key});

  @override
  ConsumerState<QuizGameplayScreen> createState() => _QuizGameplayScreenState();
}

class _QuizGameplayScreenState extends ConsumerState<QuizGameplayScreen> {
  int _currentQuestionIndex = 4; // Round 5 according to screenshot logic
  int _score = 4;
  bool _isAnswered = false;
  String? _selectedOption;
  int _timeLeft = 22;
  int _totalTime = 30;
  Timer? _timer;
  final SoundService _soundService = SoundService();

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      id: 'q5',
      code: 'fn main() {\n    let x: i32 = 42;\n    println!("Value: {}", x);\n}',
      correctAnswer: 'Rust',
      options: ['C++', 'Go', 'Rust', 'Swift'],
      description: 'fn, let, i32 and println! are Rust hallmarks',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _handleAnswer(null); 
      }
    });
  }

  void _handleAnswer(String? option) {
    if (_isAnswered) return;
    _timer?.cancel();

    final bool isCorrect = option == _questions[0].correctAnswer;

    if (isCorrect) {
      HapticFeedback.mediumImpact();
      _soundService.playCorrect();
    } else {
      HapticFeedback.heavyImpact();
      _soundService.playWrong();
    }

    setState(() {
      _isAnswered = true;
      _selectedOption = option;
      if (isCorrect) _score++;
    });

    Future.delayed(const Duration(seconds: 3), () => _showResults());
  }

  void _showResults() async {
    // Navigate back for demo
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[0];
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: const Text('Exit', style: TextStyle(fontFamily: 'DM Mono')),
                  ),
                  Row(
                    children: [
                      ...List.generate(10, (i) => Container(
                        margin: const EdgeInsets.only(left: 4),
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: i < 5 ? colorScheme.onSurface : colorScheme.outline.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      )),
                      const SizedBox(width: 12),
                      Text('5 / 10', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GameTimer(timeLeft: _timeLeft, totalTime: _totalTime),
                  const SizedBox(height: 32),
                  Text('IDENTIFY THE LANGUAGE — SYNTAX CLUE', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, letterSpacing: 1.2, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  
                  // Question Code Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1C1E),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      question.code,
                      style: const TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // Options
                  ...question.options.asMap().entries.map((e) {
                    final label = String.fromCharCode(65 + e.key); // A, B, C...
                    return _buildOption(context, label, e.value, question.correctAnswer);
                  }).toList(),
                ],
              ),
            ),
            const Spacer(),
            // Feedback Toast
            if (_isAnswered)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: colorScheme.onSurface, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(width: 32, height: 32, decoration: BoxDecoration(color: colorScheme.surface.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.check_rounded, color: Colors.white, size: 18)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Correct! That\'s ${question.correctAnswer} 🦀', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold, color: colorScheme.surface, fontSize: 14)),
                        Text('${question.description} · +10 XP', style: TextStyle(fontFamily: 'DM Mono', color: colorScheme.surface.withValues(alpha: 0.5), fontSize: 10)),
                      ])),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label, String value, String correct) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isCorrect = _isAnswered && value == correct;
    final bool isSelected = _selectedOption == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _handleAnswer(value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCorrect ? colorScheme.onSurface : colorScheme.surface,
            border: Border.all(color: isCorrect ? colorScheme.onSurface : colorScheme.outline),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: isCorrect ? colorScheme.surface.withValues(alpha: 0.1) : colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text(label, style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 12, color: isCorrect ? colorScheme.surface : colorScheme.onSurface.withValues(alpha: 0.2)))),
              ),
              const SizedBox(width: 16),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isCorrect ? colorScheme.surface : colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isCorrect) Icon(Icons.check_circle_rounded, color: colorScheme.surface, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
