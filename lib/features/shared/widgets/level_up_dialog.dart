// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taskquest/core/services/sound_service.dart';

class LevelUpDialog extends StatefulWidget {
  final int newLevel;
  final String rank;

  const LevelUpDialog({super.key, required this.newLevel, required this.rank});

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog> {
  late ConfettiController _controller;
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play();
    HapticFeedback.vibrate();
    _soundService.playLevelUp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shareAchievement() {
    SharePlus.instance.share(
      ShareParams(
        text:
            'I just reached Level ${widget.newLevel} (${widget.rank}) on TaskQuest! 🚀 #TaskQuest #CS #LearningQuest',
        subject: 'TaskQuest Level Up!',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Confetti ────────────────────────────────────────────────
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.orange,
                Colors.white,
                Colors.amber,
                Colors.yellow,
              ],
              numberOfParticles: 20,
              gravity: 0.1,
            ),
          ),

          // ── Glow Effect ─────────────────────────────────────────────
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 100,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),

          // ── Main Card ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _shareAchievement,
                      icon: Icon(
                        Icons.ios_share_rounded,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.orange,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'LEVEL UP!',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 12,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Level ${widget.newLevel}',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.rank.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'You unlocked new challenges and rewards. Keep pushing the boundaries of your knowledge.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 11,
                    height: 1.6,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _soundService.playTap();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.onSurface,
                      foregroundColor: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'CONTINUE QUEST',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
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
