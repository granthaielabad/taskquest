import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/games/models/game_models.dart';

class GameResultsScreen extends ConsumerStatefulWidget {
  final GameResult result;
  final String gameTitle;

  const GameResultsScreen({
    super.key,
    required this.result,
    required this.gameTitle,
  });

  @override
  ConsumerState<GameResultsScreen> createState() => _GameResultsScreenState();
}

class _GameResultsScreenState extends ConsumerState<GameResultsScreen> {
  // Logic removed here as it is now handled correctly by GameEngineNotifier 
  // to prevent double XP and doubled notifications.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emoji_events_rounded, color: colorScheme.surface, size: 40),
              ),
              const SizedBox(height: 32),
              
              Text(
                'QUEST COMPLETE',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 12,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.gameTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  color: colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 48),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildResultStat('SCORE', '${widget.result.score}/${widget.result.totalQuestions}'),
                  _buildResultStat('ACCURACY', '${(widget.result.accuracy * 100).toInt()}%'),
                  _buildResultStat('XP', '+${widget.result.xpEarned}'),
                ],
              ),
              
              const SizedBox(height: 64),
              
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onSurface,
                    foregroundColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text(
                    'BACK TO GAMES',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
