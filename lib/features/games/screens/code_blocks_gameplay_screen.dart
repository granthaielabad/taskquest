import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/home/providers/activity_provider.dart';
import 'package:taskquest/features/badges/providers/badge_provider.dart';
import 'package:taskquest/features/games/widgets/game_timer.dart';
import 'package:taskquest/features/shared/widgets/report_dialog.dart';

class CodeBlocksGameplayScreen extends ConsumerStatefulWidget {
  const CodeBlocksGameplayScreen({super.key});

  @override
  ConsumerState<CodeBlocksGameplayScreen> createState() => _CodeBlocksGameplayScreenState();
}

class _CodeBlocksGameplayScreenState extends ConsumerState<CodeBlocksGameplayScreen> {
  int _timeLeft = 35;
  int _totalTime = 35;
  Timer? _timer;
  String? _placedValue;
  bool _showFeedback = false;
  bool _isCorrect = false;

  final String _correctValue = 'sum(numbers)';
  final List<String> _options = ['sum(numbers)', 'max(numbers)', 'count(numbers)', 'len(numbers)', 'sorted(numbers)'];

  @override
  void initState() {
    super.initState();
    _initializeDifficulty();
    _startTimer();
  }

  void _initializeDifficulty() {
    final user = ref.read(userProfileProvider).value;
    final level = user?.level ?? 1;
    if (level >= 8) _totalTime = 15;
    else if (level >= 4) _totalTime = 25;
    else _totalTime = 35;
    _timeLeft = _totalTime;
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
        _timer?.cancel();
        _showGameOver();
      }
    });
  }

  void _checkSolution(String value) async {
    final isCorrect = value == _correctValue;
    setState(() {
      _placedValue = value;
      _showFeedback = true;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      HapticFeedback.vibrate();
      _timer?.cancel();
      final user = ref.read(currentUserProvider);
      if (user != null) {
        await ref.read(userServiceProvider).addXp(user.uid, 100);
        await ref.read(badgeServiceProvider).checkBugHunter(user.uid);
        await ref.read(activityServiceProvider).recordActivity(
          user.uid,
          ActivityModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Code Blocks Mastered',
            subtitle: 'Completed syntax challenge',
            xpReward: 100,
            timestamp: DateTime.now(),
            type: ActivityType.game,
          ),
        );
      }
      Future.delayed(const Duration(seconds: 2), () => _showSuccessDialog());
    } else {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showFeedback = false);
      });
    }
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Time\'s Up!', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); setState(() { _timeLeft = _totalTime; _placedValue = null; }); _startTimer(); }, child: const Text('RETRY')),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('QUIT')),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Correct!', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You filled in the missing code correctly.', style: TextStyle(fontFamily: 'DM Mono', fontSize: 13)),
            SizedBox(height: 20),
            Text('🔥 +100 XP Earned', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold, color: Colors.orange)),
          ],
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('DONE', style: TextStyle(fontFamily: 'DM Mono', fontWeight: FontWeight.bold))),
        ],
      ),
    );
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
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: const Text('Exit', style: TextStyle(fontFamily: 'DM Mono')),
                  ),
                  Row(
                    children: [
                      ...List.generate(6, (i) => Container(
                        margin: const EdgeInsets.only(left: 4),
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: i < 2 ? colorScheme.onSurface : colorScheme.outline.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      )),
                      const SizedBox(width: 12),
                      Text('2 / 6', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: colorScheme.onSurfaceVariant)),
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
                  Text('COMPLETE THE FUNCTION', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, letterSpacing: 1.2, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  
                  // Code Editor
                  Container(
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
                              Row(children: List.generate(3, (i) => Container(margin: const EdgeInsets.only(right: 6), width: 8, height: 8, decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle)))),
                              const SizedBox(width: 12),
                              const Text('puzzle_02.py', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: Colors.white24)),
                            ],
                          ),
                        ),
                        // Code Body
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCodeLine(1, 'def calculate_average(numbers):', color: const Color(0xFF7BA3F5)),
                              _buildCodeLine(2, '    if not numbers:', color: const Color(0xFFCCCCCC)),
                              _buildCodeLine(3, '        return 0', color: const Color(0xFFF5A623)),
                              Row(
                                children: [
                                  _buildLineNum(4),
                                  const Text('        return ', style: TextStyle(fontFamily: 'DM Mono', fontSize: 13, color: Color(0xFF7BA3F5))),
                                  DragTarget<String>(
                                    onAcceptWithDetails: (details) => _checkSolution(details.data),
                                    builder: (context, candidate, _) => Container(
                                      width: 80, height: 24,
                                      decoration: BoxDecoration(
                                        color: candidate.isNotEmpty ? Colors.white12 : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                                      ),
                                      child: Center(child: Text(_placedValue ?? '---', style: const TextStyle(color: Colors.white38, fontFamily: 'DM Mono', fontSize: 11))),
                                    ),
                                  ),
                                ],
                              ),
                              _buildCodeLine(5, '               / len(numbers)', color: const Color(0xFFCCCCCC)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text('AVAILABLE BLOCKS — DRAG TO FILL', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, letterSpacing: 1.2, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  
                  // Options
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: _options.map((opt) => Draggable<String>(
                      data: opt,
                      feedback: _buildBlock(opt, isDragging: true),
                      childWhenDragging: Opacity(opacity: 0.3, child: _buildBlock(opt)),
                      child: _buildBlock(opt),
                    )).toList(),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Feedback Toast
            if (_showFeedback)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: colorScheme.onSurface, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(width: 32, height: 32, decoration: BoxDecoration(color: colorScheme.surface.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(_isCorrect ? Icons.check_rounded : Icons.close_rounded, color: colorScheme.surface, size: 18)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_isCorrect ? '$_placedValue placed correctly!' : 'Incorrect placement', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold, color: colorScheme.surface, fontSize: 14)),
                        Text(_isCorrect ? '1 blank remaining' : 'Try a different block', style: TextStyle(fontFamily: 'DM Mono', color: colorScheme.surface.withValues(alpha: 0.5), fontSize: 10)),
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

  Widget _buildLineNum(int n) => SizedBox(width: 24, child: Text('$n ', style: const TextStyle(fontFamily: 'DM Mono', fontSize: 11, color: Colors.white10)));

  Widget _buildCodeLine(int n, String text, {required Color color}) {
    return Row(children: [_buildLineNum(n), Text(text, style: TextStyle(fontFamily: 'DM Mono', fontSize: 13, color: color))]);
  }

  Widget _buildBlock(String label, {bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E1DC)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: isDragging ? [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))] : null,
      ),
      child: Text(label, style: const TextStyle(fontFamily: 'DM Mono', fontSize: 12, color: Color(0xFF111111))),
    );
  }
}
