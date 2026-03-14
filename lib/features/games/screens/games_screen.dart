import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modes = [
      {'title': 'Flashcards', 'tag': 'AI · Featured', 'icon': Icons.style_rounded},
      {'title': 'Code Blocks', 'tag': 'Interactive', 'icon': Icons.code_rounded},
      {'title': 'Which Lang?', 'tag': 'Quiz', 'icon': Icons.quiz_rounded},
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
                  return Container(
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
                        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                      ),
                    ]),
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