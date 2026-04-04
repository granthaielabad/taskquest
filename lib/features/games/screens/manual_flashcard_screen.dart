import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';
import 'package:taskquest/features/games/providers/flashcard_provider.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';

class ManualFlashcardScreen extends ConsumerStatefulWidget {
  const ManualFlashcardScreen({super.key});

  @override
  ConsumerState<ManualFlashcardScreen> createState() => _ManualFlashcardScreenState();
}

class _ManualFlashcardScreenState extends ConsumerState<ManualFlashcardScreen> {
  final _titleController = TextEditingController();
  final _titleFocus = FocusNode();
  
  final List<TextEditingController> _termControllers = [TextEditingController()];
  final List<TextEditingController> _defControllers = [TextEditingController()];
  final List<FocusNode> _termFocusNodes = [FocusNode()];
  final List<FocusNode> _defFocusNodes = [FocusNode()];
  
  bool _isLoading = false;

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

  void _saveDeck() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a deck title')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        List<FlashcardModel> cards = [];
        for (int i = 0; i < _termControllers.length; i++) {
          if (_termControllers[i].text.isNotEmpty && _defControllers[i].text.isNotEmpty) {
            cards.add(FlashcardModel(
              id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
              term: _termControllers[i].text.trim(),
              definition: _defControllers[i].text.trim(),
            ));
          }
        }

        if (cards.isEmpty) {
          throw Exception('Add at least one card with both term and definition');
        }

        final deck = FlashcardDeckModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.uid,
          title: _titleController.text.trim(),
          type: 'Manual',
          cards: cards,
          createdAt: DateTime.now(),
        );

        await ref.read(flashcardServiceProvider).createDeck(deck);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deck saved successfully!')));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Create Manually', style: TextStyle(fontFamily: 'Syne', fontSize: 16)),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveDeck,
            child: Text('SAVE', style: TextStyle(fontFamily: 'DM Mono', color: _isLoading ? AppTheme.muted : AppTheme.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Deck Title'),
            const SizedBox(height: 8),
            TQInputField(
              controller: _titleController, 
              focusNode: _titleFocus,
              hintText: 'e.g. Midterm Review',
            ),
            const SizedBox(height: 32),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _termControllers.length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('CARD ${index + 1}', style: AppTheme.labelMono),
                        if (_termControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                            onPressed: () => setState(() {
                              _termControllers.removeAt(index);
                              _defControllers.removeAt(index);
                              _termFocusNodes.removeAt(index);
                              _defFocusNodes.removeAt(index);
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TQInputField(
                      controller: _termControllers[index], 
                      focusNode: _termFocusNodes[index],
                      hintText: 'Term / Question',
                    ),
                    const SizedBox(height: 12),
                    TQInputField(
                      controller: _defControllers[index], 
                      focusNode: _defFocusNodes[index],
                      hintText: 'Definition / Answer', 
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            
            Center(
              child: TextButton.icon(
                onPressed: _addCard,
                icon: const Icon(Icons.add_rounded, color: AppTheme.black),
                label: const Text('ADD ANOTHER CARD', style: TextStyle(fontFamily: 'DM Mono', color: AppTheme.black, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
