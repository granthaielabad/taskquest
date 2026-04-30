import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/shared/services/report_service.dart';
import 'package:taskquest/features/games/providers/game_engine_provider.dart';
import 'package:file_picker/file_picker.dart';
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
  String? _attachedFileName;

  @override
  void initState() {
    super.initState();
    // Pause game when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameEngineProvider.notifier).pauseGame();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    // Resume game when dialog closes
    // We use a small delay to ensure the dialog is fully gone
    // and avoid potential race conditions with UI rebuilds
    Future.microtask(() {
      if (ref.exists(gameEngineProvider)) {
        ref.read(gameEngineProvider.notifier).resumeGame();
      }
    });
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _attachedFileName = result.files.first.name;
      });
    }
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
        attachmentName: _attachedFileName,
      );

      debugPrint(
        'Submitting report with attachment: ${_attachedFileName ?? "None"}',
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
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Report Issue',
        style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is wrong with this question?',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 13,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Inaccurate answer, typo, bug...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'ATTACHMENT (OPTIONAL)',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 9,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _attachedFileName != null
                          ? Icons.image_rounded
                          : Icons.add_photo_alternate_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _attachedFileName ?? 'Tap to attach a photo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 11,
                          color: _attachedFileName != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (_attachedFileName != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _attachedFileName = null;
                          });
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'CANCEL',
            style: TextStyle(
              fontFamily: 'DM Mono',
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.onSurface,
            foregroundColor: colorScheme.surface,
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
