import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/games/providers/flashcard_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/badges/providers/badge_provider.dart';
import 'package:taskquest/core/services/sound_service.dart';

class StudyFlashcardScreen extends ConsumerStatefulWidget {
  final FlashcardDeckModel deck;
  const StudyFlashcardScreen({super.key, required this.deck});

  @override
  ConsumerState<StudyFlashcardScreen> createState() =>
      _StudyFlashcardScreenState();
}

class _StudyFlashcardScreenState extends ConsumerState<StudyFlashcardScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _correctCount = 0;
  final SoundService _soundService = SoundService();

  void _nextCard(bool wasCorrect) {
    if (wasCorrect) {
      _correctCount++;
      HapticFeedback.mediumImpact();
      _soundService.playCorrect();
    } else {
      HapticFeedback.heavyImpact();
      _soundService.playWrong();
    }

    if (_currentIndex < widget.deck.cards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    } else {
      _finishStudy();
    }
  }

  void _finishStudy() async {
    final mastery = ((_correctCount / widget.deck.cards.length) * 100).round();

    // 1. Save progress to deck
    await ref
        .read(flashcardServiceProvider)
        .updateMastery(widget.deck.id, mastery);

    // 2. Reward XP to user profile
    const xpReward = 50;
    await ref.read(userServiceProvider).addXp(widget.deck.userId, xpReward);

    // 3. Check for "Syntax Sage" Badge progress
    await ref
        .read(badgeServiceProvider)
        .checkSyntaxSage(widget.deck.userId, widget.deck.cards.length);

    if (mounted) {
      HapticFeedback.vibrate();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.backgroundLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Study Complete!',
            style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You mastered $mastery% of this deck.',
                style: AppTheme.bodyMono,
              ),
              const SizedBox(height: 20),
              const Text(
                '🔥 +50 XP Earned',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _soundService.playTap();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'BACK TO DECKS',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  color: AppTheme.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.deck.cards[_currentIndex];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.deck.title,
          style: const TextStyle(fontFamily: 'Syne', fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            _soundService.playTap();
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${widget.deck.cards.length}',
                style: AppTheme.labelMono,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _soundService.playTap();
                  setState(() => _isFlipped = !_isFlipped);
                },
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 400),
                  tween: Tween<double>(begin: 0, end: _isFlipped ? 180 : 0),
                  builder: (context, double val, _) {
                    final isBack = val >= 90;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(val * pi / 180),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isBack ? AppTheme.black : AppTheme.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: AppTheme.borderLight,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..rotateY(isBack ? pi : 0),
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Text(
                                isBack ? card.definition : card.term,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: isBack ? 'DM Mono' : 'Syne',
                                  fontSize: isBack ? 16 : 24,
                                  fontWeight: isBack
                                      ? FontWeight.w400
                                      : FontWeight.w800,
                                  color: isBack ? Colors.white : AppTheme.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Row(
              children: [
                _buildActionButton(
                  Icons.close_rounded,
                  'WRONG',
                  Colors.red,
                  () => _nextCard(false),
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  Icons.check_rounded,
                  'CORRECT',
                  Colors.green,
                  () => _nextCard(true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
