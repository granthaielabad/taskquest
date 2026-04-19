import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/core/providers/theme_provider.dart';
import 'flashcard_scan_screen.dart';
import 'game_lobby_screen.dart';
import 'code_blocks_gameplay_screen.dart';
import 'quiz_gameplay_screen.dart';
import 'sdlc_gameplay_screen.dart';
import 'solve_algorithm_gameplay_screen.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  String _selectedFilter = 'ALL GAMES';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userAsync = ref.watch(userProfileProvider);
    final textScale = ref.watch(textScaleProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Game\nModes',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                            height: 0.9,
                            letterSpacing: -1.2,
                            color: colorScheme.onSurface,
                          ),
                          softWrap: true,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '5 ways to level up your CS skills',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 10,
                            letterSpacing: 0.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                  userAsync.when(
                    data: (user) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, color: colorScheme.surface, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '${user?.xp ?? 0} XP',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: colorScheme.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['ALL GAMES', 'IN PROGRESS', 'COMPLETED', 'LOCKED']
                      .map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? colorScheme.surface : colorScheme.onSurface,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _selectedFilter = filter);
                        },
                        selectedColor: colorScheme.onSurface,
                        backgroundColor: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? colorScheme.onSurface : colorScheme.outline,
                          ),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Featured Card: Flashcards
              _buildFeaturedCard(context),

              const SizedBox(height: 32),

              Text(
                'ALL MODES',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  letterSpacing: 1.8,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Grid of Other Modes - Dynamic aspect ratio based on text scale
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85 / textScale.clamp(1.0, 1.4),
                children: [
                  _buildGameCard(
                    context,
                    title: 'Code Blocks',
                    desc: 'Drag & drop missing syntax into place',
                    tag: 'INTERACTIVE',
                    xp: '+150 XP',
                    points: '60',
                    icon: Icons.code_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GameLobbyScreen(
                      title: 'Code Blocks',
                      description: 'Fill in the blanks — drag the correct code blocks into the missing slots to complete working programs. Race against the clock!',
                      icon: Icons.code_rounded,
                      stats: [
                        {'value': '6', 'label': 'PUZZLES'},
                        {'value': '190', 'label': 'BEST XP'},
                        {'value': '+150', 'label': 'XP REWARD'},
                        {'value': '6m', 'label': 'EST. TIME'},
                      ],
                      configOptions: {
                        'Language': ['Python', 'JavaScript', 'Java', 'C++'],
                        'Difficulty': ['Beginner', 'Intermediate', 'Advanced'],
                        'Topic': ['All Topics', 'Loops', 'Functions', 'OOP'],
                      },
                      startButtonText: 'Start Coding',
                      gameScreen: CodeBlocksGameplayScreen(),
                    ))),
                  ),
                  _buildGameCard(
                    context,
                    title: 'Which Lang?',
                    desc: 'Identify from descriptions & syntax',
                    tag: 'QUIZ',
                    xp: '+100 XP',
                    points: '40',
                    icon: Icons.quiz_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GameLobbyScreen(
                      title: 'Which Lang?',
                      description: 'Identify programming languages from clues — syntax snippets, descriptions, or fun facts. How many can you get right?',
                      icon: Icons.quiz_rounded,
                      stats: [
                        {'value': '10', 'label': 'QUESTIONS'},
                        {'value': '8/10', 'label': 'BEST SCORE'},
                        {'value': '+100', 'label': 'XP REWARD'},
                        {'value': '4m', 'label': 'EST. TIME'},
                      ],
                      configOptions: {
                        'Clue Type': ['Mix of All', 'Syntax Only', 'Description', 'Fun Facts'],
                        'Language Pool': ['All (20 langs)', 'Popular 10', 'Beginner Set'],
                        'Time per Question': ['45s', '30s', '15s'],
                      },
                      startButtonText: 'Start Quiz',
                      gameScreen: QuizGameplayScreen(),
                    ))),
                  ),
                  _buildGameCard(
                    context,
                    title: 'SDLC Sequence',
                    desc: 'Arrange software dev phases in order',
                    tag: 'PUZZLE',
                    xp: '+120 XP',
                    points: '80',
                    icon: Icons.account_tree_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GameLobbyScreen(
                      title: 'SDLC Sequence',
                      description: 'Master the lifecycle — arrange software development phases in the correct order to earn experience points.',
                      icon: Icons.account_tree_rounded,
                      stats: [
                        {'value': '5', 'label': 'ROUNDS'},
                        {'value': '0', 'label': 'BEST SCORE'},
                        {'value': '+120', 'label': 'XP REWARD'},
                        {'value': '5m', 'label': 'EST. TIME'},
                      ],
                      configOptions: {
                        'Project Type': ['Web App', 'Mobile App', 'Embedded System'],
                        'Difficulty': ['Normal', 'Hard', 'Expert'],
                        'Rounds': ['5 Rounds', '10 Rounds'],
                      },
                      startButtonText: 'Begin SDLC',
                      gameScreen: SdlcGameplayScreen(),
                    ))),
                  ),
                  _buildGameCard(
                    context,
                    title: 'Solve Algorithm',
                    desc: 'Work through logic problems step by step',
                    tag: 'LOGIC',
                    xp: '+200 XP',
                    points: '20',
                    icon: Icons.functions_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GameLobbyScreen(
                      title: 'Solve Algorithm',
                      description: 'Trace and solve — analyze pseudocode and determine the correct output. Sharpen your logical thinking skills.',
                      icon: Icons.functions_rounded,
                      stats: [
                        {'value': '8', 'label': 'STEPS'},
                        {'value': '0', 'label': 'BEST SCORE'},
                        {'value': '+200', 'label': 'XP REWARD'},
                        {'value': '8m', 'label': 'EST. TIME'},
                      ],
                      configOptions: {
                        'Algorithm Type': ['Search', 'Sorting', 'Graph', 'Math'],
                        'Difficulty': ['Beginner', 'Intermediate', 'Advanced'],
                        'Language': ['Pseudocode', 'Python', 'C++'],
                      },
                      startButtonText: 'Solve Problem',
                      gameScreen: SolveAlgorithmGameplayScreen(),
                    ))),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorScheme.surface.withValues(alpha: 0.1)),
                ),
                child: Icon(Icons.style_rounded, color: colorScheme.surface, size: 24),
              ),
              Row(
                children: [
                  _buildTag(context, 'AI ✦', isDark: true),
                  const SizedBox(width: 8),
                  _buildTag(context, 'FEATURED', isDark: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Flashcards',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 32,
              color: colorScheme.surface,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 12),
          Text(
            'Create your own reviewer manually or upload any document — our AI scans it and builds a full card deck automatically.',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 11,
              height: 1.5,
              color: colorScheme.surface.withValues(alpha: 0.5),
            ),
            softWrap: true,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStat('48', 'CARDS DONE'),
                      const SizedBox(width: 24),
                      _buildStat('+120', 'AVG XP'),
                      const SizedBox(width: 24),
                      _buildStat('85%', 'ACCURACY'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FlashcardScanScreen())),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.play_arrow_rounded, color: colorScheme.onSurface, size: 32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(BuildContext context, String label, {bool isDark = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String desc,
    required String tag,
    required String xp,
    required String points,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(24),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: colorScheme.onSurface, size: 18),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.onSurface, width: 1.5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          points,
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(), // Only scroll if absolutely necessary
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          desc,
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 9,
                            height: 1.2,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: _buildTag(context, tag)),
                    const SizedBox(width: 4),
                    Text(
                      xp,
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
