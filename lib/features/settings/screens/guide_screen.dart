import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text(
                      'Guide',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: theme.colorScheme.outline, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  _GuideItem(
                    title: '1. Complete Quests',
                    description: 'Navigate to the Home tab to view your daily and weekly quests. Complete them to earn XP and level up!',
                    icon: Icons.assignment_turned_in_rounded,
                  ),
                  _GuideItem(
                    title: '2. Play Minigames',
                    description: 'Go to the Games tab to practice your coding skills with interactive challenges like Syntax, Logic, and Architecture minigames.',
                    icon: Icons.gamepad_rounded,
                  ),
                  _GuideItem(
                    title: '3. Scan Flashcards',
                    description: 'Use the AI Flashcard scanner to quickly turn your study notes into interactive flashcard decks.',
                    icon: Icons.document_scanner_rounded,
                  ),
                  _GuideItem(
                    title: '4. Earn Badges',
                    description: 'Check out the Badges tab to track your achievements and show off your progress to other scholars.',
                    icon: Icons.stars_rounded,
                  ),
                  _GuideItem(
                    title: '5. Customize Your Profile',
                    description: 'Head to the Profile tab to change your avatar, customize the app appearance, and tweak your notification settings.',
                    icon: Icons.person_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _GuideItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
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
