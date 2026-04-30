// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/games/models/game_models.dart';
import 'package:taskquest/core/providers/theme_provider.dart';
import 'package:taskquest/features/games/providers/game_engine_provider.dart';
import 'flashcard_scan_screen.dart';
import 'game_lobby_screen.dart';
import 'code_blocks_gameplay_screen.dart';
import 'quiz_gameplay_screen.dart';
import 'sdlc_gameplay_screen.dart';
import 'solve_algorithm_gameplay_screen.dart';
import 'syntax_sniper_gameplay_screen.dart';

import 'package:taskquest/features/shared/widgets/scale_on_tap.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  String _selectedFilter = 'ALL MODES';

  @override
  void initState() {
    super.initState();
    // ── Performance: Warm up game cache ─────────────────────
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmUpGames();
    });
  }

  Future<void> _warmUpGames() async {
    final service = ref.read(gameContentServiceProvider);
    // Pre-fetch popular modes in background
    service.warmUp(
      GameSessionConfig(
        title: 'Syntax Sniper',
        type: GameType.syntaxSniper,
        options: {'Language': 'Python'},
      ),
    );
    service.warmUp(
      GameSessionConfig(
        title: 'Code Blocks',
        type: GameType.codeBlocks,
        options: {'Language': 'Python', 'Difficulty': 'Beginner'},
      ),
    );
  }

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: colorScheme.surface,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${user?.xp ?? 0} XP',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: colorScheme.surface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (e, st) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['ALL MODES', 'SYNTAX', 'LOGIC', 'ARCHITECTURE']
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
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? colorScheme.surface
                                    : colorScheme.onSurface,
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
                                color: isSelected
                                    ? colorScheme.onSurface
                                    : colorScheme.outline,
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
              const SizedBox(height: 32),
              if (_selectedFilter == 'ALL MODES') ...[
                _buildFeaturedCard(context),
                const SizedBox(height: 32),
              ],
              Text(
                _selectedFilter == 'ALL MODES'
                    ? 'ALL MODES'
                    : '$_selectedFilter CHALLENGES',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  letterSpacing: 1.8,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _buildGamesGrid(context, textScale),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGamesGrid(BuildContext context, double textScale) {
    final List<_GameCardWidget> allGames = [
      _GameCardWidget(
        title: 'Syntax Sniper',
        desc: 'Quickly spot syntax errors in code snippets',
        tag: 'SYNTAX',
        icon: Icons.biotech_rounded,
        onTap: () => _navigateToLobby(
          context,
          'Syntax Sniper',
          'Quickly scan code snippets and identify if they contain syntax errors.',
          Icons.biotech_rounded,
          [
            {'value': '10', 'label': 'QUESTIONS'},
            {'value': '85%', 'label': 'AVG ACCURACY'},
            {'value': '+20', 'label': 'XP/CORRECT'},
            {'value': '3m', 'label': 'EST. TIME'},
          ],
          {
            'Language': ['All', 'Python', 'JavaScript', 'Java'],
            'Difficulty': ['Easy', 'Medium', 'Hard'],
            'Questions': ['5', '10', '20'],
          },
          'Start Sniping',
          const SyntaxSniperGameplayScreen(),
          GameType.syntaxSniper,
        ),
      ),
      _GameCardWidget(
        title: 'Code Blocks',
        desc: 'Drag & drop missing syntax into place',
        tag: 'SYNTAX',
        icon: Icons.code_rounded,
        onTap: () => _navigateToLobby(
          context,
          'Code Blocks',
          'Fill in the blanks by dragging correct code blocks into the editor.',
          Icons.code_rounded,
          [
            {'value': '10', 'label': 'PUZZLES'},
            {'value': '190', 'label': 'BEST XP'},
            {'value': '+150', 'label': 'XP REWARD'},
            {'value': '6m', 'label': 'EST. TIME'},
          ],
          {
            'Language': ['Python', 'JavaScript', 'Java', 'C++'],
            'Topic': ['All', 'Logic', 'Loops', 'Functions'],
            'Difficulty': ['Beginner', 'Intermediate'],
          },
          'Start Coding',
          const CodeBlocksGameplayScreen(),
          GameType.codeBlocks,
        ),
      ),
      _GameCardWidget(
        title: 'Which Lang?',
        desc: 'Identify from descriptions & syntax',
        tag: 'SYNTAX',
        icon: Icons.quiz_rounded,
        onTap: () => _navigateToLobby(
          context,
          'Which Lang?',
          'Identify programming languages from snippets, hallmarks, or fun facts.',
          Icons.quiz_rounded,
          [
            {'value': '10', 'label': 'QUESTIONS'},
            {'value': '8/10', 'label': 'BEST SCORE'},
            {'value': '+100', 'label': 'XP REWARD'},
            {'value': '4m', 'label': 'EST. TIME'},
          ],
          {
            'Clue Type': ['Mixed', 'Syntax', 'Hallmarks', 'Purpose'],
            'Pool': ['Popular', 'System', 'Web', 'Legacy'],
            'Time': ['15s', '10s', '5s'],
          },
          'Start Quiz',
          const QuizGameplayScreen(),
          GameType.quiz,
        ),
      ),
      _GameCardWidget(
        title: 'SDLC Sequence',
        desc: 'Arrange software dev phases in order',
        tag: 'ARCHITECTURE',
        icon: Icons.account_tree_rounded,
        onTap: () => _navigateToLobby(
          context,
          'SDLC Sequence',
          'Master the lifecycle by arranging phases in correct order for various models.',
          Icons.account_tree_rounded,
          [
            {'value': '5', 'label': 'ROUNDS'},
            {'value': '100%', 'label': 'TOP ACCURACY'},
            {'value': '+120', 'label': 'XP REWARD'},
            {'value': '5m', 'label': 'EST. TIME'},
          ],
          {
            'Model Type': ['Mixed', 'Waterfall', 'Agile', 'Spiral'],
            'Difficulty': ['Normal', 'Expert'],
          },
          'Begin SDLC',
          const SdlcGameplayScreen(),
          GameType.sdlc,
        ),
      ),
      _GameCardWidget(
        title: 'Solve Algorithm',
        desc: 'Work through logic problems step by step',
        tag: 'LOGIC',
        icon: Icons.functions_rounded,
        onTap: () => _navigateToLobby(
          context,
          'Solve Algorithm',
          'Trace and solve complex logic and pseudocode challenges.',
          Icons.functions_rounded,
          [
            {'value': '8', 'label': 'STEPS'},
            {'value': 'Gold', 'label': 'RANK'},
            {'value': '+200', 'label': 'XP REWARD'},
            {'value': '8m', 'label': 'EST. TIME'},
          ],
          {
            'Category': ['All', 'Sorting', 'Search', 'Big O'],
            'Difficulty': ['Beginner', 'Advanced'],
          },
          'Solve Problem',
          const SolveAlgorithmGameplayScreen(),
          GameType.algorithm,
        ),
      ),
    ];

    final List<Widget> filteredGames = _selectedFilter == 'ALL MODES'
        ? allGames
        : allGames.where((g) => g.tag == _selectedFilter).toList();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85 / textScale.clamp(1.0, 1.4),
      children: filteredGames,
    );
  }

  void _navigateToLobby(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    List<Map<String, String>> stats,
    Map<String, List<String>> configOptions,
    String startButtonText,
    Widget gameScreen,
    GameType gameType,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameLobbyScreen(
          title: title,
          description: description,
          icon: icon,
          stats: stats,
          configOptions: configOptions,
          startButtonText: startButtonText,
          gameScreen: gameScreen,
          gameType: gameType,
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ScaleOnTap(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FlashcardScanScreen()),
      ),
      child: Container(
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
                    border: Border.all(
                      color: colorScheme.surface.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.style_rounded,
                    color: colorScheme.surface,
                    size: 24,
                  ),
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
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: colorScheme.onSurface,
                    size: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) => Column(
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
  Widget _buildTag(BuildContext context, String label, {bool isDark = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : colorScheme.onSurface.withValues(alpha: 0.05),
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
}

class _GameCardWidget extends StatelessWidget {
  final String title, desc, tag;
  final IconData icon;
  final VoidCallback onTap;
  const _GameCardWidget({
    required this.title,
    required this.desc,
    required this.tag,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
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
                    border: Border.all(
                      color: colorScheme.onSurface,
                      width: 1.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
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
              children: [Flexible(child: _buildTag(context, tag))],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
