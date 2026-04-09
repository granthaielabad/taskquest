import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/shared/services/report_service.dart';
import 'package:uuid/uuid.dart';

class ReportDialog extends ConsumerStatefulWidget {
  final String gameType;
  final String contentId;

  const ReportDialog({
    super.key,
    required this.gameType,
    required this.contentId,
  });

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reasonController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    final user = ref.read(currentUserProvider);
    if (user != null) {
      final report = ReportModel(
        id: const Uuid().v4(),
        userId: user.uid,
        gameType: widget.gameType,
        contentId: widget.contentId,
        reason: _reasonController.text.trim(),
        timestamp: DateTime.now(),
      );

      await ref.read(reportServiceProvider).submitReport(report);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Report Issue',
        style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is wrong with this question?',
            style: TextStyle(fontFamily: 'DM Mono', fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            style: const TextStyle(fontFamily: 'DM Mono', fontSize: 13),
            decoration: InputDecoration(
              hintText: 'e.g. Inaccurate answer, typo, bug...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(fontFamily: 'DM Mono')),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.onSurface,
            foregroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('SUBMIT', style: TextStyle(fontFamily: 'DM Mono')),
        ),
      ],
    );
  }
}
