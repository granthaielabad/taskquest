import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/home/providers/activity_provider.dart';
import 'package:taskquest/features/badges/providers/badge_provider.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';
import 'package:taskquest/features/games/widgets/game_timer.dart';
import 'package:taskquest/features/shared/widgets/report_dialog.dart';

class CodeBlocksScreen extends ConsumerStatefulWidget {
  const CodeBlocksScreen({super.key});

  @override
  ConsumerState<CodeBlocksScreen> createState() => _CodeBlocksScreenState();
}

class _CodeBlocksScreenState extends ConsumerState<CodeBlocksScreen> {
  int _timeLeft = 35;
  int _totalTime = 35;
  Timer? _timer;
  String? _placedValue;

  final String _correctValue = '"Hello, "';
  final List<String> _options = ['"Hello, "', 'console.log', 'null'];

  @override
  void initState() {
    super.initState();
    _initializeDifficulty();
    _startTimer();
  }

  void _initializeDifficulty() {
    final user = ref.read(userProfileProvider).value;
    final level = user?.level ?? 1;

    if (level >= 8) {
      _totalTime = 15;
    } else if (level >= 4) {
      _totalTime = 25;
    } else {
      _totalTime = 35;
    }
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

  void _checkSolution() async {
    if (_placedValue == _correctValue) {
      HapticFeedback.vibrate();
      _timer?.cancel();

      final user = ref.read(currentUserProvider);
      if (user != null) {
        await ref.read(userServiceProvider).addXp(user.uid, 100);
        await ref.read(badgeServiceProvider).checkBugHunter(user.uid);
        
        // Record activity
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

      if (mounted) {
        _showSuccessDialog();
      }
    } else {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not quite right. Try again!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Time\'s Up!',
          style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Try to think faster next time!',
          style: TextStyle(fontFamily: 'DM Mono'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _timeLeft = _totalTime;
                _placedValue = null;
              });
              _startTimer();
            },
            child: const Text('RETRY'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('QUIT'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Correct!',
          style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You filled in the missing code correctly.',
              style: TextStyle(fontFamily: 'DM Mono', fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Text(
              '🔥 +100 XP Earned',
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'DONE',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => const ReportDialog(
        gameType: 'code_blocks',
        contentId: 'greet_function_missing_hello',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Code Blocks',
          style: TextStyle(fontFamily: 'Syne', fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem_outlined, size: 20),
            tooltip: 'Report Issue',
            onPressed: _showReportDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GameTimer(timeLeft: _timeLeft, totalTime: _totalTime),
            const SizedBox(height: 24),

            const FieldLabel('FILL IN THE MISSING CODE'),
            const SizedBox(height: 12),

            // Code block card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 14,
                        height: 1.8,
                      ),
                      children: [
                        const TextSpan(
                          text: 'function ',
                          style: TextStyle(color: Color(0xFF7BA3F5)),
                        ),
                        const TextSpan(
                          text: 'greet',
                          style: TextStyle(color: Colors.white),
                        ),
                        const TextSpan(
                          text: '(name) {\n  ',
                          style: TextStyle(color: Color(0xFFCCCCCC)),
                        ),
                        const TextSpan(
                          text: 'return ',
                          style: TextStyle(color: Color(0xFF7BA3F5)),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: DragTarget<String>(
                            onAcceptWithDetails: (details) {
                              setState(() {
                                _placedValue = details.data;
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                width: 80,
                                height: 24,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: candidateData.isNotEmpty
                                      ? Colors.white24
                                      : const Color(0xFF333333),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _placedValue != null
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _placedValue ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'DM Mono',
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const TextSpan(
                          text: ' + name;\n}',
                          style: TextStyle(color: Color(0xFFCCCCCC)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const FieldLabel('DRAG A CHIP INTO THE SLOT'),
            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _options.map((option) {
                final isPlaced = _placedValue == option;
                return Draggable<String>(
                  data: option,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _CodeChip(label: option, isDragging: true),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _CodeChip(label: option),
                  ),
                  child: Opacity(
                    opacity: isPlaced ? 0.3 : 1.0,
                    child: _CodeChip(label: option),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 48),

            TQButton(
              label: 'CHECK SOLUTION',
              isLoading: false,
              onTap: _placedValue == null ? null : _checkSolution,
            ),

            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _placedValue = null;
                  });
                },
                child: Text(
                  'RESET',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeChip extends StatelessWidget {
  final String label;
  final bool isDragging;
  const _CodeChip({required this.label, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        border: Border.all(
          color: isDragging ? Colors.white : const Color(0xFF444444),
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 12,
          color: Color(0xFFCCCCCC),
        ),
      ),
    );
  }
}
