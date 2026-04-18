import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/services/sound_service.dart';
import 'package:taskquest/features/games/widgets/game_timer.dart';

class SolveAlgorithmGameplayScreen extends ConsumerStatefulWidget {
  const SolveAlgorithmGameplayScreen({super.key});

  @override
  ConsumerState<SolveAlgorithmGameplayScreen> createState() => _SolveAlgorithmGameplayScreenState();
}

class _SolveAlgorithmGameplayScreenState extends ConsumerState<SolveAlgorithmGameplayScreen> {
  int _timeLeft = 17;
  int _totalTime = 30;
  Timer? _timer;
  bool _isAnswered = false;
  String? _selectedOption;
  final SoundService _soundService = SoundService();

  final List<String> _options = ['25', '15', '120', '5'];
  final String _correct = '120';

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
      if (_timeLeft > 0) setState(() => _timeLeft--);
      else _timer?.cancel();
    });
  }

  void _handleAnswer(String option) {
    if (_isAnswered) return;
    _timer?.cancel();
    setState(() {
      _isAnswered = true;
      _selectedOption = option;
    });
    if (option == _correct) {
      HapticFeedback.mediumImpact();
      _soundService.playCorrect();
    } else {
      HapticFeedback.heavyImpact();
      _soundService.playWrong();
    }
    Future.delayed(const Duration(seconds: 3), () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
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
                  TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left_rounded), label: const Text('Exit', style: TextStyle(fontFamily: 'DM Mono'))),
                  Row(children: [
                    ...List.generate(8, (i) => Container(margin: const EdgeInsets.only(left: 4), width: 6, height: 6, decoration: BoxDecoration(color: i < 3 ? colorScheme.onSurface : colorScheme.outline.withValues(alpha: 0.3), shape: BoxShape.circle))),
                    const SizedBox(width: 12),
                    Text('3 / 8', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: colorScheme.onSurfaceVariant)),
                  ]),
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
                  Text('TRACE THE OUTPUT — WHAT DOES THIS PRINT?', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, letterSpacing: 1.2, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  
                  // Pseudocode Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: const Color(0xFF1A1C1E), borderRadius: BorderRadius.circular(24)),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'DM Mono', fontSize: 13, height: 1.8),
                        children: [
                          const TextSpan(text: 'SET ', style: TextStyle(color: Color(0xFF7BA3F5))),
                          const TextSpan(text: 'n = 5\n', style: TextStyle(color: Colors.white)),
                          const TextSpan(text: 'SET ', style: TextStyle(color: Color(0xFF7BA3F5))),
                          const TextSpan(text: 'result = 1\n', style: TextStyle(color: Colors.white)),
                          const TextSpan(text: 'WHILE ', style: TextStyle(color: Color(0xFFD67BFF))),
                          const TextSpan(text: 'n > 0 ', style: TextStyle(color: Colors.white)),
                          const TextSpan(text: 'DO\n', style: TextStyle(color: Color(0xFFD67BFF))),
                          const TextSpan(text: '    result = result × n\n', style: TextStyle(color: Colors.white70)),
                          const TextSpan(text: '    n = n - 1\n', style: TextStyle(color: Colors.white70)),
                          const TextSpan(text: 'END WHILE\n', style: TextStyle(color: Color(0xFFD67BFF))),
                          const TextSpan(text: 'PRINT ', style: TextStyle(color: Color(0xFFF5A623))),
                          const TextSpan(text: 'result', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // Options
                  ..._options.asMap().entries.map((e) {
                    final label = String.fromCharCode(65 + e.key);
                    return _buildOption(context, label, e.value);
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
                      Container(width: 32, height: 32, decoration: BoxDecoration(color: colorScheme.surface.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(_selectedOption == _correct ? Icons.check_rounded : Icons.close_rounded, color: Colors.white, size: 18)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_selectedOption == _correct ? 'Correct! 5! = 120' : 'Incorrect result', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold, color: colorScheme.surface, fontSize: 14)),
                        Text('This is a factorial algorithm: 5×4×3×2×1 = 120 · +25 XP', style: TextStyle(fontFamily: 'DM Mono', color: colorScheme.surface.withValues(alpha: 0.5), fontSize: 10)),
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

  Widget _buildOption(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isCorrect = _isAnswered && value == _correct;
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
              Text(value, style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 15, color: isCorrect ? colorScheme.surface : colorScheme.onSurface)),
              const Spacer(),
              if (isCorrect) Icon(Icons.check_circle_rounded, color: colorScheme.surface, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
