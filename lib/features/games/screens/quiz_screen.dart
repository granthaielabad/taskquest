import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/badges/providers/badge_provider.dart';

class QuizQuestion {
  final String code;
  final String correctAnswer;
  final List<String> options;

  QuizQuestion({
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
  Timer? _timer;

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      code: 'public static void main(String[] args) {\n  System.out.println("Hello");\n}',
      correctAnswer: 'Java',
      options: ['C++', 'Java', 'C#', 'JavaScript'],
    ),
    QuizQuestion(
      code: 'def hello_world():\n    print("Hello, World!")',
      correctAnswer: 'Python',
      options: ['Ruby', 'Python', 'PHP', 'Swift'],
    ),
    QuizQuestion(
      code: 'const [count, setCount] = useState(0);',
      correctAnswer: 'JavaScript',
      options: ['TypeScript', 'JavaScript', 'Java', 'Dart'],
    ),
    QuizQuestion(
      code: 'fn main() {\n    println!("Hello!");\n}',
      correctAnswer: 'Rust',
      options: ['C', 'Go', 'Rust', 'Kotlin'],
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
    _timeLeft = 15;
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

    setState(() {
      _isAnswered = true;
      _selectedOption = option;
      if (option == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isAnswered = false;
          _selectedOption = null;
        });
        _startTimer();
      } else {
        _showResults();
      }
    });
  }

  void _showResults() async {
    final xpEarned = _score * 25;
    final isPerfect = _score == _questions.length;
    final user = ref.read(authStateProvider).value;
    
    if (user != null) {
      if (xpEarned > 0) {
        await ref.read(userServiceProvider).addXp(user.uid, xpEarned);
      }
      // Check for Logic Master badge
      await ref.read(badgeServiceProvider).checkLogicMaster(user.uid, isPerfect);
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Quiz Finished!', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You got $_score / ${_questions.length} correct.', style: AppTheme.bodyMono),
              const SizedBox(height: 20),
              Text('🔥 +$xpEarned XP Earned', style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('DONE', style: TextStyle(fontFamily: 'DM Mono', color: AppTheme.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Which Lang?', style: TextStyle(fontFamily: 'Syne', fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                '$_timeLeft',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _timeLeft < 5 ? Colors.red : AppTheme.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation(AppTheme.black),
              minHeight: 4,
            ),
            const SizedBox(height: 32),
            
            // Code block
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
            
            // Options
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
    Color borderColor = AppTheme.border;
    Color bgColor = AppTheme.white;
    Widget? icon;

    if (_isAnswered) {
      if (option == correctAnswer) {
        borderColor = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.1);
        icon = const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20);
      } else if (option == _selectedOption) {
        borderColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.1);
        icon = const Icon(Icons.cancel_rounded, color: Colors.red, size: 20);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _handleAnswer(option),
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
              if (icon != null) icon,
            ],
          ),
        ),
      ),
    );
  }
}
