import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/core/services/sound_service.dart';

class LevelUpDialog extends StatefulWidget {
  final int newLevel;
  final String rank;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    required this.rank,
  });

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
        text: 'I just reached Level ${widget.newLevel} (${widget.rank}) on TaskQuest! 🚀 #TaskQuest #CS #LearningQuest',
        subject: 'TaskQuest Level Up!',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.white.withValues(alpha: 0.2),
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
              color: AppTheme.black,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _shareAchievement,
                      icon: const Icon(Icons.ios_share_rounded, color: Colors.white54, size: 20),
                    ),
                  ],
                ),
                const Icon(Icons.auto_awesome_rounded, color: Colors.orange, size: 48),
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
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.rank.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: Color(0xFF777777),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'You unlocked new challenges and rewards. Keep pushing the boundaries of your knowledge.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 11,
                    height: 1.6,
                    color: Color(0xFF999999),
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
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
