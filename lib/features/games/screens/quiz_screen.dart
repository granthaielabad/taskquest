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

  QuizQuestion({
    required this.id,
    required this.code,
    required this.correctAnswer,
    required this.options,
  });
}

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  String? _selectedOption;
  int _timeLeft = 15;
  int _totalTime = 15;
  Timer? _timer;
  final SoundService _soundService = SoundService();

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      id: 'q1',
      code:
          'public static void main(String[] args) {\n  System.out.println("Hello");\n}',
      correctAnswer: 'Java',
      options: ['C++', 'Java', 'C#', 'JavaScript'],
    ),
    QuizQuestion(
      id: 'q2',
      code: 'def hello_world():\n    print("Hello, World!")',
      correctAnswer: 'Python',
      options: ['Ruby', 'Python', 'PHP', 'Swift'],
    ),
    QuizQuestion(
      id: 'q3',
      code: 'const [count, setCount] = useState(0);',
      correctAnswer: 'JavaScript',
      options: ['TypeScript', 'JavaScript', 'Java', 'Dart'],
    ),
    QuizQuestion(
      id: 'q4',
      code: 'fn main() {\n    println!("Hello!");\n}',
      correctAnswer: 'Rust',
      options: ['C', 'Go', 'Rust', 'Kotlin'],
    ),
  ];

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
      _totalTime = 8;
    } else if (level >= 4) {
      _totalTime = 12;
    } else {
      _totalTime = 15;
    }
    _timeLeft = _totalTime;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = _totalTime;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _handleAnswer(null); // Time out
      }
    });
  }

  void _handleAnswer(String? option) {
    if (_isAnswered) return;
    _timer?.cancel();

    final bool isCorrect =
        option == _questions[_currentQuestionIndex].correctAnswer;

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
      if (isCorrect) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        if (mounted) {
          setState(() {
            _currentQuestionIndex++;
            _isAnswered = false;
            _selectedOption = null;
          });
          _startTimer();
        }
      } else {
        _showResults();
      }
    });
  }

  void _showResults() async {
    final xpEarned = _score * 25;
    final isPerfect = _score == _questions.length;
    final user = ref.read(currentUserProvider);

    if (user != null) {
      if (xpEarned > 0) {
        await ref.read(userServiceProvider).addXp(user.uid, xpEarned);
        
        // Record activity
        await ref.read(activityServiceProvider).recordActivity(
              user.uid,
              ActivityModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Quiz Finished',
                subtitle: 'Got $_score / ${_questions.length} correct',
                xpReward: xpEarned,
                timestamp: DateTime.now(),
                type: ActivityType.game,
              ),
            );
      }
      await ref
          .read(badgeServiceProvider)
          .checkLogicMaster(user.uid, isPerfect);
    }

    if (mounted) {
      HapticFeedback.vibrate();
      _soundService.playLevelUp(); // Generic achievement sound
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.backgroundLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Quiz Finished!',
            style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You got $_score / ${_questions.length} correct.',
                style: AppTheme.bodyMono,
              ),
              const SizedBox(height: 20),
              Text(
                '🔥 +$xpEarned XP Earned',
                style: const TextStyle(
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
                _soundService.playTap();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'DONE',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  color: AppTheme.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        gameType: 'quiz',
        contentId: _questions[_currentQuestionIndex].id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Which Lang?',
          style: TextStyle(fontFamily: 'Syne', fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            _soundService.playTap();
            Navigator.pop(context);
          },
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GameTimer(timeLeft: _timeLeft, totalTime: _totalTime),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: AppTheme.borderLight,
              valueColor: const AlwaysStoppedAnimation(AppTheme.black),
              minHeight: 4,
            ),
            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                question.code,
                style: const TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),

            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  return _buildOptionButton(option, question.correctAnswer);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option, String correctAnswer) {
    Color borderColor = AppTheme.borderLight;
    Color bgColor = AppTheme.white;
    Widget? icon;

    if (_isAnswered) {
      if (option == correctAnswer) {
        borderColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.1);
        icon = const Icon(
          Icons.check_circle_rounded,
          color: Colors.green,
          size: 20,
        );
      } else if (option == _selectedOption) {
        borderColor = Colors.red;
        bgColor = Colors.red.withOpacity(0.1);
        icon = const Icon(Icons.cancel_rounded, color: Colors.red, size: 20);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          _soundService.playTap();
          _handleAnswer(option);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                option,
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.black,
                ),
              ),
              ?icon,
            ],
          ),
        ),
      ),
    );
  }
}
