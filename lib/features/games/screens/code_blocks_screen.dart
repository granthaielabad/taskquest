import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/badges/providers/badge_provider.dart';

class CodeLine {
  final String content;
  final int correctIndex;

  CodeLine({required this.content, required this.correctIndex});
}

class CodeChallenge {
  final String title;
  final String language;
  final List<CodeLine> lines;

  CodeChallenge({required this.title, required this.language, required this.lines});
}

class CodeBlocksScreen extends ConsumerStatefulWidget {
  const CodeBlocksScreen({super.key});

  @override
  ConsumerState<CodeBlocksScreen> createState() => _CodeBlocksScreenState();
}

class _CodeBlocksScreenState extends ConsumerState<CodeBlocksScreen> {
  late CodeChallenge _currentChallenge;
  late List<CodeLine> _shuffledLines;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  void _loadChallenge() {
    _currentChallenge = CodeChallenge(
      title: 'Python List Comprehension',
      language: 'PYTHON',
      lines: [
        CodeLine(content: 'numbers = [1, 2, 3, 4, 5]', correctIndex: 0),
        CodeLine(content: 'squares = [x**2 for x in numbers]', correctIndex: 1),
        CodeLine(content: 'if x % 2 == 0]', correctIndex: 2),
        CodeLine(content: 'print(squares)', correctIndex: 3),
      ],
    );
    
    _shuffledLines = List.from(_currentChallenge.lines)..shuffle();
    _isSuccess = false;
  }

  void _checkSolution() async {
    bool correct = true;
    for (int i = 0; i < _shuffledLines.length; i++) {
      if (_shuffledLines[i].correctIndex != i) {
        correct = false;
        break;
      }
    }

    if (correct) {
      setState(() => _isSuccess = true);
      
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        await ref.read(userServiceProvider).addXp(user.uid, 100);
        await ref.read(badgeServiceProvider).checkBugHunter(user.uid);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correct! +100 XP Earned'), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not quite right. Try again!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Code Blocks', style: TextStyle(fontFamily: 'Syne', fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _currentChallenge.language,
                    style: const TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentChallenge.title,
                  style: AppTheme.headingL,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Drag the blocks to reorder the code correctly.',
                  style: AppTheme.bodyMono,
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _shuffledLines.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _shuffledLines.removeAt(oldIndex);
                  _shuffledLines.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final line = _shuffledLines[index];
                return Container(
                  key: ValueKey(line.content),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_indicator_rounded, color: AppTheme.dimmed, size: 20),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          line.content,
                          style: const TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 13,
                            color: AppTheme.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => setState(() => _shuffledLines.shuffle()),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('RESET', style: TextStyle(fontFamily: 'DM Mono', color: AppTheme.black)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSuccess ? null : _checkSolution,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(_isSuccess ? 'COMPLETED' : 'CHECK', style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
