import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'flashcard_scan_screen.dart';
import 'code_blocks_screen.dart';
import 'quiz_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modes = [
      {
        'title': 'Flashcards', 
        'tag': 'AI · Featured', 
        'icon': Icons.style_rounded,
        'screen': const FlashcardScanScreen()
      },
      {
        'title': 'Code Blocks', 
        'tag': 'Interactive', 
        'icon': Icons.code_rounded,
        'screen': const CodeBlocksScreen()
      },
      {
        'title': 'Which Lang?', 
        'tag': 'Quiz', 
        'icon': Icons.quiz_rounded,
        'screen': const QuizScreen()
      },
      {'title': 'SDLC Sequence', 'tag': 'Puzzle', 'icon': Icons.account_tree_rounded},
      {'title': 'Algorithm Solver', 'tag': 'Logic', 'icon': Icons.functions_rounded},
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Games', style: TextStyle(fontFamily: 'Syne',
                    fontWeight: FontWeight.w800, fontSize: 26,
                    letterSpacing: -0.78, color: AppTheme.black)),
                SizedBox(height: 4),
                Text('Choose your challenge mode',
                    style: TextStyle(fontFamily: 'DM Mono', fontSize: 10,
                        letterSpacing: 1.0, color: AppTheme.muted)),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: modes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final m = modes[i];
                  final bool hasScreen = m.containsKey('screen');

                  return GestureDetector(
                    onTap: hasScreen ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => m['screen'] as Widget),
                      );
                    } : null,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: AppTheme.background,
                              border: Border.all(color: AppTheme.border),
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(m['icon'] as IconData, color: AppTheme.black, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m['title'] as String, style: const TextStyle(
                              fontFamily: 'Syne', fontWeight: FontWeight.w700,
                              fontSize: 14, color: AppTheme.black)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.background,
                                border: Border.all(color: AppTheme.border),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(m['tag'] as String, style: const TextStyle(
                                fontFamily: 'DM Mono', fontSize: 8,
                                letterSpacing: 0.64, color: AppTheme.muted)),
                          ),
                        ])),
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(color: AppTheme.black,
                              borderRadius: BorderRadius.circular(8)),
                          child: Icon(
                            hasScreen ? Icons.arrow_forward : Icons.lock_outline_rounded, 
                            color: hasScreen ? Colors.white : Colors.white54, 
                            size: 14
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
