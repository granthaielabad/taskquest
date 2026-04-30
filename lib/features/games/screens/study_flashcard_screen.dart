// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/games/providers/flashcard_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/badges/providers/badge_provider.dart';
import 'package:taskquest/core/services/sound_service.dart';
import 'package:taskquest/features/shared/widgets/report_dialog.dart';

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
  bool _isFinishing = false;
  final SoundService _soundService = SoundService();

  void _nextCard(bool wasCorrect) {
    if (_isFinishing) return;

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

  void _finishStudy() {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);

    final sessionScore = ((_correctCount / widget.deck.cards.length) * 100)
        .round()
        .clamp(0, 100);

    // Prevent mastery from ever going down
    final finalMastery = max(widget.deck.masteryProgress, sessionScore);
    final bool wasAlreadyCompleted = widget.deck.masteryProgress >= 100;

    // ── FIRE & FORGET (Asynchronous Background Updates) ──────
    if (finalMastery > widget.deck.masteryProgress) {
      ref
          .read(flashcardServiceProvider)
          .updateMastery(widget.deck.id, finalMastery);
    }

    // Only reward XP if the deck was not already completed
    int xpReward = 0;
    if (!wasAlreadyCompleted) {
      xpReward = 50;
      ref.read(userServiceProvider).addXp(widget.deck.userId, xpReward);
    }

    ref
        .read(badgeServiceProvider)
        .checkSyntaxSage(widget.deck.userId, widget.deck.cards.length);

    // ── UI COMPLETION ──────────────────────────────────────────
    if (mounted) {
      final colorScheme = Theme.of(context).colorScheme;
      HapticFeedback.vibrate();
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent accidental dismissal
        builder: (context) => AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Study Complete!',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You mastered $sessionScore% of the cards this round.',
                style: AppTheme.bodyMono.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Overall Mastery: $finalMastery%',
                style: AppTheme.labelMono.copyWith(
                  color: finalMastery >= 100
                      ? Colors.green
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (xpReward > 0)
                const Text(
                  '🔥 +50 XP Earned',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                )
              else
                Text(
                  'Deck already completed.',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _soundService.playTap();
                Navigator.pop(context); // Close Dialog
                Navigator.pop(context); // Exit Study Screen
              },
              child: Text(
                'BACK TO DECKS',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  color: colorScheme.onSurface,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.deck.title,
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: colorScheme.onSurface),
          onPressed: () {
            _soundService.playTap();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.flag_outlined,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    ReportDialog(gameType: 'flashcards', contentId: card.id),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${widget.deck.cards.length}',
                style: AppTheme.labelMono.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
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
                          color: isBack
                              ? colorScheme.onSurface
                              : colorScheme.surface,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: colorScheme.outline,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
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
                              child: SingleChildScrollView(
                                child: Text(
                                  isBack ? card.definition : card.term,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: isBack ? 'DM Mono' : 'Syne',
                                    fontSize: isBack ? 16 : 24,
                                    fontWeight: isBack
                                        ? FontWeight.w400
                                        : FontWeight.w800,
                                    color: isBack
                                        ? colorScheme.surface
                                        : colorScheme.onSurface,
                                  ),
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
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
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
