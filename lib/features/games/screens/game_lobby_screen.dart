import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/games/models/game_models.dart';
import 'package:taskquest/features/games/providers/game_engine_provider.dart';

class GameLobbyScreen extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Map<String, String>> stats;
  final Map<String, List<String>> configOptions;
  final String startButtonText;
  final Widget gameScreen;
  final GameType gameType;

  const GameLobbyScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.stats,
    required this.configOptions,
    required this.startButtonText,
    required this.gameScreen,
    required this.gameType,
  });

  @override
  ConsumerState<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends ConsumerState<GameLobbyScreen> {
  final Map<String, String> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    // Default select first option for each category
    widget.configOptions.forEach((key, values) {
      if (values.isNotEmpty) _selectedOptions[key] = values.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gameState = ref.watch(gameEngineProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.chevron_left_rounded, color: colorScheme.onSurface),
          label: Text(
            'Games',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 12,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        leadingWidth: 100,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            widget.icon,
                            color: colorScheme.surface,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                            color: colorScheme.surface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 11,
                            height: 1.5,
                            color: colorScheme.surface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Stats Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: widget.stats
                                .map(
                                  (s) => Padding(
                                    padding: const EdgeInsets.only(right: 24),
                                    child: _buildStat(s['value']!, s['label']!),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    'CONFIGURE SESSION',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      letterSpacing: 1.8,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Config Options
                  ...widget.configOptions.entries.map(
                    (entry) => _buildConfigSection(entry.key, entry.value),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Start Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: gameState.status == GameSessionStatus.loading
                    ? null
                    : () async {
                        final config = GameSessionConfig(
                          title: widget.title,
                          type: widget.gameType,
                          options: _selectedOptions,
                        );

                        await ref
                            .read(gameEngineProvider.notifier)
                            .initializeGame(config);

                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => widget.gameScreen,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.onSurface,
                  foregroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: gameState.status == GameSessionStatus.loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              widget.startButtonText.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                              maxLines: 1, // Ensure text does not wrap too aggressively
                              overflow: TextOverflow.ellipsis, // Add ellipsis if it still overflows
                            ),
                          ),
                        ],
                      ),
              ),
            ),
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

  Widget _buildConfigSection(String title, List<String> options) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 9,
              letterSpacing: 1.0,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected = _selectedOptions[title] == opt;
              return ChoiceChip(
                label: Text(
                  opt,
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
                  if (val) setState(() => _selectedOptions[title] = opt);
                },
                selectedColor: colorScheme.onSurface,
                backgroundColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected
                        ? colorScheme.onSurface
                        : colorScheme.outline,
                  ),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
