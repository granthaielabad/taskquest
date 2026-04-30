import 'package:flutter/material.dart';

/// A reusable dialog to confirm if the user wants to exit a game session.
class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Exit Game?',
        style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Are you sure you want to exit? Your current progress will be lost.',
        style: TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 13,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'CANCEL',
            style: TextStyle(
              fontFamily: 'DM Mono',
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text('EXIT', style: TextStyle(fontFamily: 'DM Mono')),
        ),
      ],
    );
  }
}
