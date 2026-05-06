import 'package:flutter/material.dart';

class GameTimer extends StatelessWidget {
  final int timeLeft;
  final int totalTime;
  final String label;

  const GameTimer({
    super.key,
    required this.timeLeft,
    required this.totalTime,
    this.label = 'TIME REMAINING',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLowTime = timeLeft < (totalTime * 0.3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 12,
                      letterSpacing: 1.2,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                '00:${timeLeft.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  letterSpacing: 1.0,
                  color: isLowTime ? Colors.red : colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: timeLeft / totalTime,
              minHeight: 5,
              backgroundColor: colorScheme.outline,
              valueColor: AlwaysStoppedAnimation(
                isLowTime ? Colors.red : colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
