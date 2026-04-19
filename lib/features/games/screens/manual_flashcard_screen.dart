import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';
import 'package:taskquest/features/games/providers/flashcard_provider.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';

class ManualFlashcardScreen extends ConsumerStatefulWidget {
  const ManualFlashcardScreen({super.key});

  @override
  ConsumerState<ManualFlashcardScreen> createState() =>
      _ManualFlashcardScreenState();
}

class _ManualFlashcardScreenState extends ConsumerState<ManualFlashcardScreen> {
  final _titleController = TextEditingController();
  final _titleFocus = FocusNode();

  final List<TextEditingController> _termControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _defControllers = [TextEditingController()];
  final List<FocusNode> _termFocusNodes = [FocusNode()];
  final List<FocusNode> _defFocusNodes = [FocusNode()];

  final Set<int> _errorIndices = {};
  bool _titleError = false;
  bool _isLoading = false;
  String _selectedCategory = 'General';

  final List<String> _categories = [
    'General',
    'Data Structures',
    'Algorithms',
    'Operating Systems',
    'Networking',
    'Database',
    'Security',
  ];

  @override
  void initState() {
    super.initState();
    _titleFocus.addListener(() => setState(() {}));
    _termFocusNodes[0].addListener(() => setState(() {}));
    _defFocusNodes[0].addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocus.dispose();
    for (var c in _termControllers) {
      c.dispose();
    }
    for (var c in _defControllers) {
      c.dispose();
    }
    for (var f in _termFocusNodes) {
      f.dispose();
    }
    for (var f in _defFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _hasChanges {
    if (_titleController.text.isNotEmpty) {
      return true;
    }
    for (var c in _termControllers) {
      if (c.text.isNotEmpty) {
        return true;
      }
    }
    for (var c in _defControllers) {
      if (c.text.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  void _addCard() {
    final termFocus = FocusNode();
    final defFocus = FocusNode();
    termFocus.addListener(() => setState(() {}));
    defFocus.addListener(() => setState(() {}));

    setState(() {
      _termControllers.add(TextEditingController());
      _defControllers.add(TextEditingController());
      _termFocusNodes.add(termFocus);
      _defFocusNodes.add(defFocus);
    });
  }

  void _clearAll() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Clear All?',
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'This will delete all content you have typed.',
          style: AppTheme.bodyMono.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CANCEL',
              style: TextStyle(
                fontFamily: 'DM Mono',
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'CLEAR',
              style: TextStyle(
                fontFamily: 'DM Mono',
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _titleController.clear();
        _termControllers.clear();
        _defControllers.clear();
        _termFocusNodes.clear();
        _defFocusNodes.clear();
        _errorIndices.clear();
        _titleError = false;
        _selectedCategory = 'General';

        // Reset to one empty card
        _termControllers.add(TextEditingController());
        _defControllers.add(TextEditingController());
        final tf = FocusNode();
        final df = FocusNode();
        tf.addListener(() => setState(() {}));
        df.addListener(() => setState(() {}));
        _termFocusNodes.add(tf);
        _defFocusNodes.add(df);
      });
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges) {
      return true;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Discard Changes?',
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'You have unsaved cards. Are you sure you want to leave?',
          style: AppTheme.bodyMono.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'KEEP EDITING',
              style: TextStyle(
                fontFamily: 'DM Mono',
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'DISCARD',
              style: TextStyle(
                fontFamily: 'DM Mono',
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _saveDeck() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    setState(() {
      _errorIndices.clear();
      _titleError = _titleController.text.trim().isEmpty;
    });

    if (_titleError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a deck title'),
          backgroundColor: colorScheme.error,
        ),
      );
      _titleFocus.requestFocus();
      return;
    }

    List<FlashcardModel> cards = [];
    bool hasIncomplete = false;

    for (int i = 0; i < _termControllers.length; i++) {
      final term = _termControllers[i].text.trim();
      final def = _defControllers[i].text.trim();

      if (term.isNotEmpty && def.isNotEmpty) {
        cards.add(
          FlashcardModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
            term: term,
            definition: def,
          ),
        );
      } else if (term.isNotEmpty || def.isNotEmpty) {
        setState(() => _errorIndices.add(i));
        hasIncomplete = true;
      }
    }

    if (hasIncomplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete all cards or remove empty ones'),
          backgroundColor: isDark ? Colors.orangeAccent : Colors.orange,
        ),
      );
      return;
    }

    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one complete card'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final deck = FlashcardDeckModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.uid,
          title: _titleController.text.trim(),
          type: 'Manual',
          category: _selectedCategory,
          cards: cards,
          createdAt: DateTime.now(),
        );

        await ref.read(flashcardServiceProvider).createDeck(deck);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Deck saved to cloud!'),
              backgroundColor: isDark ? Colors.lightGreenAccent : Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Create Manually',
            style: TextStyle(fontFamily: 'Syne', fontSize: 16),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
            onPressed: () => Navigator.maybePop(context),
          ),
          actions: [
            if (!_isLoading) ...[
              IconButton(
                onPressed: _clearAll,
                icon: Icon(
                  Icons.delete_sweep_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _saveDeck,
                child: Text(
                  'SAVE',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Deck Title'),
                    const SizedBox(height: 8),
                    TQInputField(
                      controller: _titleController,
                      focusNode: _titleFocus,
                      hintText: 'e.g. Midterm Review',
                      hasError: _titleError,
                    ),
                    const SizedBox(height: 32),
                    const FieldLabel('Category'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? colorScheme.onSurface : colorScheme.surface,
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.onSurface
                                : colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? colorScheme.surface : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _termControllers.length,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(
                        color: _errorIndices.contains(index)
                            ? colorScheme.error
                            : colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CARD ${index + 1}',
                              style: AppTheme.labelMono.copyWith(
                                color: _errorIndices.contains(index)
                                    ? colorScheme.error
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (_termControllers.length > 1)
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: colorScheme.error,
                                  size: 18,
                                ),
                                onPressed: () => setState(() {
                                  _termControllers.removeAt(index);
                                  _defControllers.removeAt(index);
                                  _termFocusNodes.removeAt(index);
                                  _defFocusNodes.removeAt(index);
                                  _errorIndices.clear();
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TQInputField(
                          controller: _termControllers[index],
                          focusNode: _termFocusNodes[index],
                          hintText: 'Term / Question',
                          hasError:
                              _errorIndices.contains(index) &&
                              _termControllers[index].text.isEmpty,
                        ),
                        const SizedBox(height: 12),
                        TQInputField(
                          controller: _defControllers[index],
                          focusNode: _defFocusNodes[index],
                          hintText: 'Definition / Answer',
                          maxLines: 2,
                          hasError:
                              _errorIndices.contains(index) &&
                              _defControllers[index].text.isEmpty,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Center(
                child: TextButton.icon(
                  onPressed: _addCard,
                  icon: Icon(Icons.add_rounded, color: colorScheme.onSurface),
                  label: Text(
                    'ADD ANOTHER CARD',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      color: colorScheme.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
}
