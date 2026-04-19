import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/games/providers/flashcard_provider.dart';
import 'package:taskquest/features/games/screens/study_flashcard_screen.dart';

class AllDecksScreen extends ConsumerStatefulWidget {
  const AllDecksScreen({super.key});

  @override
  ConsumerState<AllDecksScreen> createState() => _AllDecksScreenState();
}

class _AllDecksScreenState extends ConsumerState<AllDecksScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDecksAsync = ref.watch(userDecksProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'My Library',
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontFamily: 'DM Mono', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search your library...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: userDecksAsync.when(
              data: (decks) {
                final filtered = decks.where((d) => 
                  d.title.toLowerCase().contains(_query) || 
                  d.category.toLowerCase().contains(_query)
                ).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.style_outlined, size: 48, color: colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          _query.isEmpty ? 'Your library is empty' : 'No matches found',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final deck = filtered[index];
                    return _buildDeckTile(context, deck);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckTile(BuildContext context, FlashcardDeckModel deck) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StudyFlashcardScreen(deck: deck)),
          );
        },
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.onSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            deck.type == 'AI' ? Icons.auto_awesome_motion_rounded : Icons.style_rounded,
            color: colorScheme.surface,
            size: 20,
          ),
        ),
        title: Text(
          deck.title,
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${deck.cards.length} cards · ${deck.category}',
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${deck.masteryProgress}%',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
